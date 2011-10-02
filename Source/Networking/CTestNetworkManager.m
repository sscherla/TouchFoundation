//
//  CTestNetworkManager.m
//  toxicsoftware.com
//
//  Created by Jonathan Wight on 9/30/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CTestNetworkManager.h"

#define RND() (float)arc4random() / (float)UINT32_MAX

@implementation CTestNetworkManager

@synthesize successCount;
@synthesize failureRate;

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        successCount = 3;
        failureRate = 1.0f;
        }
    return self;
    }

- (void)sendRequest:(NSURLRequest *)request shouldBackground:(BOOL)inShouldBackground completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;
    {
    if (self.successCount > 0)
        {
        self.successCount--;
        }
    else
        {
        if (self.failureRate > 0.0f && RND() <= self.failureRate)
            {
            LogDebug_(@"Pretending to fail a request.");
            if (handler)
                {
                NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"We're pretending to fail here.", NSLocalizedDescriptionKey,
                    NULL];
                NSError *theError = [NSError errorWithDomain:@"TODO_DOMAIN" code:-1 userInfo:theUserInfo];
                handler(NULL, NULL, theError);
                return;
                }
            }
        }
    

    [super sendRequest:request shouldBackground:inShouldBackground completionHandler:handler];
    }

@end
