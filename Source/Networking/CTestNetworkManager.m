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
