//
//  CTestNetworkManager.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/30/11.
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
//  THIS SOFTWARE IS PROVIDED BY 2011 TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 2011 TOXICSOFTWARE.COM OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of 2011 toxicsoftware.com.

#import "CTestNetworkManager.h"

#define RND() (float)arc4random() / (float)UINT32_MAX

@interface CTestNetworkManager()
- (void)failRequest:(NSURLRequest *)request handler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;
@end

#pragma mark -

@implementation CTestNetworkManager

@synthesize enabled;
@synthesize successCount;
@synthesize failureRate;
@synthesize failurePattern;
@synthesize delayTime;

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        enabled = NO;
        successCount = 3;
        failureRate = 1.0f;
        failurePattern = NULL;
        delayTime = 10.0;
        }
    return self;
    }

- (void)sendRequest:(NSURLRequest *)request shouldBackground:(BOOL)inShouldBackground completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;
    {
    if (self.enabled == YES)
        {
        if (self.successCount > 0)
            {
            self.successCount--;
            }
        else
            {
            BOOL theShouldFailFlag = NO;

            if (self.failurePattern.length > 0)
                {
                NSError *theError = NULL;
                NSRegularExpression *theExpression = [NSRegularExpression regularExpressionWithPattern:self.failurePattern options:NSRegularExpressionCaseInsensitive error:&theError];
               if ([theExpression firstMatchInString:request.URL.absoluteString options:0 range:(NSRange){ .length = request.URL.absoluteString.length }] != NULL)
                    {
                    theShouldFailFlag = YES;
                    }
                }
            
            if (self.failureRate > 0.0f && RND() <= self.failureRate)
                {
                theShouldFailFlag = YES;
                }

            if (self.delayTime > 0.0)
                {
                #if TARGET_OS_IPHONE == 1
                UIBackgroundTaskIdentifier theBackgroundTaskIdentifier = UIBackgroundTaskInvalid;
                if (inShouldBackground)
                    {
                    theBackgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
                    NSLog(@"Background Task Identifier: %d", theBackgroundTaskIdentifier);
                    }
                #endif /* TARGET_OS_IPHONE == 1 */

                NSLog(@"DELAYING...");
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    NSLog(@"FIRING...");
                    if (theShouldFailFlag == YES)
                        {
                        [self failRequest:request handler:handler];
                        return;
                        }
                    else
                        {
                        [super sendRequest:request shouldBackground:inShouldBackground completionHandler:handler];
                        }

                    #if TARGET_OS_IPHONE == 1
                    if (inShouldBackground)
                        {
                        [[UIApplication sharedApplication] endBackgroundTask:theBackgroundTaskIdentifier];
                        }
                    #endif /* TARGET_OS_IPHONE == 1 */
                    });
                }
            else
                {
                if (theShouldFailFlag == YES)
                    {
                    [self failRequest:request handler:handler];
                    return;
                    }
                else
                    {
                    [super sendRequest:request shouldBackground:inShouldBackground completionHandler:handler];
                    }
                }
            }

        }
    else
        {
        [super sendRequest:request shouldBackground:inShouldBackground completionHandler:handler];
        }
    }

- (void)failRequest:(NSURLRequest *)request handler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;
    {
    LogInfo_(@"Pretending to fail a request.");
    if (handler)
        {
        NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
            @"We're pretending to fail here.", NSLocalizedDescriptionKey,
            request, @"request",
            NULL];
        NSError *theError = [NSError errorWithDomain:@"TODO_DOMAIN" code:-1 userInfo:theUserInfo];
        handler(NULL, NULL, theError);
        }
    }

@end
