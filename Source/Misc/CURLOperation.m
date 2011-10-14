//
//  CURLOperation.m
//  TouchCode
//
//  Created by Jonathan Wight on 10/21/09.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

#import "CURLOperation.h"

#import "CTemporaryData.h"

@interface CURLOperation ()
@property (readwrite, assign) BOOL isExecuting;
@property (readwrite, assign) BOOL isFinished;
@property (readwrite, strong) NSURLRequest *request;
@property (readwrite, strong) NSURLConnection *connection;
@property (readwrite, strong) NSURLResponse *response;
@property (readwrite, strong) NSError *error;
@property (readwrite, strong) CTemporaryData *temporaryData;
@end

@implementation CURLOperation

@synthesize isExecuting;
@synthesize isFinished;
@synthesize request;
@synthesize connection;
@synthesize response;
@synthesize error;
@synthesize temporaryData;
@synthesize defaultCredential;
@synthesize userInfo;

- (id)initWithRequest:(NSURLRequest *)inRequest
	{
	if ((self = [super init]) != NULL)
		{
		isExecuting = NO;
		isFinished = NO;

		request = [inRequest copy];
		}
	return(self);
	}

#pragma mark -

- (BOOL)isConcurrent
	{
	return(YES);
	}

- (NSData *)data
	{
	return(self.temporaryData.data);
	}

#pragma mark -

- (void)start
	{
	@try
		{
		self.isExecuting = YES;
		self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];

//		[self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

        [self.connection setDelegateQueue:[NSOperationQueue currentQueue]];



		[self.connection start];

        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
		}
	@catch (NSException * e)
		{
		NSLog(@"EXCEPTION CAUGHT: %@", e);
		}
	}

- (void)cancel
	{
	[self.connection cancel];
	self.connection = NULL;
	//
	[super cancel];
	}

#pragma mark -

- (void)didReceiveData:(NSData *)inData
	{
	if (self.isCancelled)
		{
		return;
		}

	if (self.temporaryData == NULL)
		{
		self.temporaryData = [[CTemporaryData alloc] initWithMemoryLimit:64 * 1024];
		}
	NSError *theError = NULL;
	BOOL theResult = [self.temporaryData appendData:inData error:&theError];
	if (theResult == NO)
		{
		self.error = theError;
		[self cancel];
		}
	}

- (void)didFinish
	{
	self.connection = NULL;

	[self willChangeValueForKey:@"isFinished"];
	isFinished = YES;
	[self didChangeValueForKey:@"isFinished"];

	[self willChangeValueForKey:@"isExecuting"];
	isExecuting = NO;
	[self didChangeValueForKey:@"isExecuting"];
	}

- (void)didFailWithError:(NSError *)inError
	{
	self.connection = NULL;

	self.error = inError;

	[self willChangeValueForKey:@"isFinished"];
	isFinished = YES;
	[self didChangeValueForKey:@"isFinished"];

	[self willChangeValueForKey:@"isExecuting"];
	isExecuting = NO;
	[self didChangeValueForKey:@"isExecuting"];
	}

#pragma mark -

- (NSURLRequest *)connection:(NSURLConnection *)inConnection willSendRequest:(NSURLRequest *)inRequest redirectResponse:(NSURLResponse *)response
	{
	return(inRequest);
	}

- (void)connection:(NSURLConnection *)inConnection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)inChallenge
	{
	if (self.defaultCredential == NULL || [inChallenge previousFailureCount] > 1)
		{
		[[inChallenge sender] cancelAuthenticationChallenge:inChallenge];
		}

	[[inChallenge sender] useCredential:self.defaultCredential forAuthenticationChallenge:inChallenge];
	}


- (void)connection:(NSURLConnection *)inConnection didReceiveResponse:(NSURLResponse *)inResponse
	{
	self.response = inResponse;
	}

- (void)connection:(NSURLConnection *)inConnection didReceiveData:(NSData *)inData
	{
	[self didReceiveData:inData];
	}

- (void)connectionDidFinishLoading:(NSURLConnection *)inConnection
	{
	NSInteger statusCode = [(NSHTTPURLResponse *)self.response statusCode];
	if (statusCode >= 400)
		{
		NSString *body = [[NSString alloc] initWithBytes:[self.data bytes] length:[self.data length] encoding:NSUTF8StringEncoding];
		NSError *err = [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:[NSDictionary dictionaryWithObject:body forKey:NSLocalizedDescriptionKey]];
		[self didFailWithError:err];
		}
	else
		{
		[self didFinish];
		}
	}

- (void)connection:(NSURLConnection *)inConnection didFailWithError:(NSError *)inError
	{
	[self didFailWithError:inError];
	}

@end
