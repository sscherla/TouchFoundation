//
//  CHTTPClient.h
//  TouchFoundation
//
//  Created by Jonathan Wight on 10/23/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTemporaryData;

@protocol CHTTPClientDelegate;

@interface CHTTPClient : NSObject {
}

@property (readwrite, nonatomic, assign) NSUInteger initialBufferLength;
@property (readwrite, nonatomic, assign) NSUInteger bufferLength;
@property (readwrite, nonatomic, weak) id <CHTTPClientDelegate> delegate;    

- (id)initWithRequest:(NSURLRequest *)inRequest;

- (void)main;

@end

#pragma mark -

@protocol CHTTPClientDelegate <NSObject>
@optional
- (void)httpClient:(CHTTPClient *)inClient didReceiveResponse:(NSURLResponse *)inResponse;
- (void)httpClientDidFinishLoading:(CHTTPClient *)inClient;
- (void)httpClient:(CHTTPClient *)inClient didFailWithError:(NSError *)inError;
- (void)httpClient:(CHTTPClient *)inClient didReceiveData:(NSData *)inData;
@end