//
//  CNetworkManager.h
//  toxicsoftware.com
//
//  Created by Jonathan Wight on 9/15/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNetworkManager : NSObject

+ (CNetworkManager *)sharedInstance;

- (void)sendRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;
- (void)sendRequest:(NSURLRequest *)request shouldBackground:(BOOL)inShouldBackground completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;

@end
