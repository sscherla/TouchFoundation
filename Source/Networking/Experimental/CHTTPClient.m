//
//	CHTTPClient.m
//	TouchCode
//
//	Created by Jonathan Wight on 10/23/10.
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

#import "CHTTPClient.h"

#import "CTemporaryData.h"
#import "CMyURLResponse.h"

@interface CHTTPClient ()
@property (readwrite, nonatomic, strong) NSURLRequest *request;
@property (readwrite, nonatomic, strong) __attribute__((NSObject)) CFReadStreamRef readStream;
@property (readwrite, nonatomic, strong) NSMutableData *initialBuffer;
@property (readwrite, nonatomic, strong) NSMutableData *buffer;
@property (readwrite, nonatomic, strong) CTemporaryData *data;
@property (readwrite, nonatomic, strong) __attribute__((NSObject)) CFHTTPMessageRef requestMessage;
@property (readwrite, nonatomic, strong) __attribute__((NSObject)) CFHTTPMessageRef responseMessage;

- (void)open;
- (void)process;
- (void)close;

- (void)readContent;

@end

#pragma mark -

@implementation CHTTPClient

@synthesize data = _data;

- (id)initWithRequest:(NSURLRequest *)inRequest
    {
    if ((self = [super init]) != NULL)
        {
        _request = inRequest;
        _initialBufferLength = 32 * 1024;
        _bufferLength = 32 * 1024;
        }
    return(self);
    }

#pragma mark -

- (CTemporaryData *)data
    {
    if (_data == NULL)
        {
        _data = [[CTemporaryData alloc] initWithMemoryLimit:8 * 1024 * 1024];
        }
    return(_data);
    }

#pragma mark -

- (void)main
    {
    [self open];
    [self process];
    [self close];
    }

- (void)open
    {
    self.requestMessage = CFHTTPMessageCreateRequest(kCFAllocatorDefault, CFSTR("GET"), (__bridge CFURLRef)self.request.URL, kCFHTTPVersion1_1);
    CFHTTPMessageSetHeaderFieldValue(self.requestMessage, CFSTR("Host"), (__bridge CFStringRef)self.request.URL.host);

    self.initialBuffer = [NSMutableData dataWithLength:self.initialBufferLength];
    self.buffer = [NSMutableData dataWithLength:self.bufferLength];
    }

- (void)process
    {
    self.readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, self.requestMessage);
    CFReadStreamSetProperty(self.readStream, kCFStreamPropertyHTTPShouldAutoredirect, kCFBooleanTrue);

    CFReadStreamOpen(self.readStream);

    CFIndex theBytesRead = CFReadStreamRead(self.readStream, self.initialBuffer.mutableBytes, self.initialBuffer.length);
    self.initialBuffer.length = theBytesRead;

    self.responseMessage = (CFHTTPMessageRef)CFReadStreamCopyProperty(self.readStream, kCFStreamPropertyHTTPResponseHeader);

    if ([self.delegate respondsToSelector:@selector(httpClient:didReceiveResponse:)])
        {
        CMyURLResponse *theResponse = [[CMyURLResponse alloc] initWithMessage:self.responseMessage];
        [self.delegate httpClient:self didReceiveResponse:theResponse];
        }

    CFIndex theStatusCode = CFHTTPMessageGetResponseStatusCode(self.responseMessage);
    NSDictionary *theRequestHeaders = (__bridge_transfer id)CFHTTPMessageCopyAllHeaderFields(self.requestMessage);

    NSDictionary *theResponseHeaders = (__bridge_transfer id)CFHTTPMessageCopyAllHeaderFields(self.responseMessage);
    if (theStatusCode == 401)
        {
        if ([theRequestHeaders objectForKey:@"Authorization"])
            {
            NSLog(@"Bad auth");
            return;
            }

        CFHTTPAuthenticationRef theAuthentication = CFHTTPAuthenticationCreateFromResponse(kCFAllocatorDefault, self.responseMessage);
        if (theAuthentication == NULL)
            {
            NSLog(@"Bad auth");
            return;
            }
        CFStreamError theError;
        BOOL theFlag = CFHTTPAuthenticationIsValid(theAuthentication, &theError);
        NSLog(@"AUTH? %d", theFlag);

//        NSDictionary *theCredentials = [NSDictionary dictionaryWithObjectsAndKeys:
//            @"schwa", (id)kCFHTTPAuthenticationUsername,
//            @"*****", (id)kCFHTTPAuthenticationPassword,
//            NULL];
//
//        theFlag = CFHTTPMessageApplyCredentialDictionary(self.requestMessage, theAuthentication, theCredentials, &theError);
//        NSLog(@"CRED? %d", theFlag);
//
//        [self process];

        CFRelease(theAuthentication);

        return;
        }


    if ([self.request.HTTPMethod isEqualToString:@"HEAD"] || (theStatusCode >= 100 && theStatusCode <= 199) || theStatusCode == 204 || theStatusCode == 304)
        {
        NSLog(@"No body");
        }
    else if ([(id)theResponseHeaders objectForKey:@"Transfer-Encoding"] && [[(id)theResponseHeaders objectForKey:@"Transfer-Encoding"] isEqualToString:@"identity"] == NO)
        {
        NSLog(@"CHUNKED?");
        [self readContent];
        }
    else
        {
        [self readContent];
        }
    }

- (void)close
    {
	NSLog(@"CLOSE");

    if (_readStream)
        {
        CFReadStreamClose(self.readStream);
        }

	if (self.delegate && [self.delegate respondsToSelector:@selector(httpClientDidFinishLoading:)])
		{
		[self.delegate httpClientDidFinishLoading:self];
		}
    }

#pragma mark -

- (void)readContent
    {
    self.data = [[CTemporaryData alloc] initWithMemoryLimit:1 * 1024 * 1024];
    [self.data appendData:(id)self.initialBuffer error:NULL];

    do
        {
        CFIndex theBytesRead = CFReadStreamRead(self.readStream, [self.buffer mutableBytes], self.buffer.length);

		if (self.delegate && [self.delegate respondsToSelector:@selector(httpClient:didReceiveData:)])
			{
			// TODO bytes nocopy?
			NSData *theData = [NSData dataWithBytes:[self.buffer mutableBytes] length:theBytesRead];
			[self.delegate httpClient:self didReceiveData:theData];
			}

        [self.data appendBytes:[self.buffer mutableBytes] length:theBytesRead error:NULL];
        }
    while (CFReadStreamGetStatus(self.readStream) == kCFStreamStatusOpen);
    }

@end
