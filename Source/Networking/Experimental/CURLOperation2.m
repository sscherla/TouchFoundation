//
//	CURLOperation2.m
//	TouchCode
//
//	Created by Jonathan Wight on 10/26/10.
//	Copyright 2011 toxicsoftware.com. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	   1. Redistributions of source code must retain the above copyright notice, this list of
//		  conditions and the following disclaimer.
//
//	   2. Redistributions in binary form must reproduce the above copyright notice, this list
//		  of conditions and the following disclaimer in the documentation and/or other materials
//		  provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL TOXICSOFTWARE.COM OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of toxicsoftware.com.

#import "CURLOperation2.h"

#import "CHTTPClient.h"

@interface CURLOperation2 () <CHTTPClientDelegate>
@property (readwrite, strong) NSURLResponse *response;
@property (readwrite, strong) NSError *error;
@end

#pragma mark -

@implementation CURLOperation2

@synthesize request;
@synthesize response;
@synthesize error;

- (id)initWithRequest:(NSURLRequest *)inRequest;
    {
    if ((self = [super init]) != NULL)
        {
        request = [inRequest copy];
        }
    return(self);
    }

- (void)main
    {
    CHTTPClient *theClient = [[CHTTPClient alloc] initWithRequest:self.request];
    theClient.delegate = self;
    [theClient main];
    }

#pragma mark -

- (void)didReceiveData:(NSData *)inData
    {
	NSLog(@"DID RECEIVE DATA");
    }

- (void)didFinish
    {
	NSLog(@"DID FINISH");
    }

- (void)didFailWithError:(NSError *)inError
    {
	self.error = inError;
    }

#pragma mark -

- (void)httpClient:(CHTTPClient *)inClient didReceiveResponse:(NSURLResponse *)inResponse;
    {
	self.response = inResponse;
    }

- (void)httpClientDidFinishLoading:(CHTTPClient *)inClient;
	{
	[self didFinish];
	}

- (void)httpClient:(CHTTPClient *)inClient didReceiveData:(NSData *)inData
	{
	[self didReceiveData:inData];
	}

@end
