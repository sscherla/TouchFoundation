//
//  CNetworkManager.m
//  toxicsoftware.com
//
//  Created by Jonathan Wight on 9/15/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CNetworkManager.h"

#import "CTestNetworkManager.h"

@interface CNetworkManager ()
@property (readwrite, nonatomic, retain) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, assign) NSInteger connectionCount;
@end

@implementation CNetworkManager

@synthesize operationQueue;
@synthesize connectionCount;

static CNetworkManager *gSharedInstance = NULL;

+ (CNetworkManager *)sharedInstance
    {
    #warning TODO make a user default pref
    static dispatch_once_t sOnceToken = 0;
    dispatch_once(&sOnceToken, ^{
    
        #warning TODO make a user default pref
        #if DEBUG == 1
        gSharedInstance = [[CTestNetworkManager alloc] init];
        #else
        gSharedInstance = [[CNetworkManager alloc] init];
        #endif
        });
    return(gSharedInstance);
    }

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        operationQueue = [NSOperationQueue mainQueue];
        }
    return self;
    }

- (void)setConnectionCount:(NSInteger)inConnectionCount
    {
    if (connectionCount == 0 && inConnectionCount == 1)
        {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
    else if (connectionCount == 1 && inConnectionCount == 0)
        {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    connectionCount = inConnectionCount;
    }

- (void)sendRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
    {
    [self sendRequest:request shouldBackground:NO completionHandler:handler];
    }

- (void)sendRequest:(NSURLRequest *)request shouldBackground:(BOOL)inShouldBackground completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;
    {
    self.connectionCount += 1;

    UIBackgroundTaskIdentifier theBackgroundTaskIdentifier = UIBackgroundTaskInvalid;
    if (inShouldBackground)
        {
        theBackgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
        }

    [NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        BOOL theHandledFlag = NO;
    
        if (error == NULL)
            {
            NSHTTPURLResponse *theHTTPResponse = AssertCast_(NSHTTPURLResponse, response);

            if (theHTTPResponse.statusCode < 200 || theHTTPResponse.statusCode >= 400)
                {
                NSMutableDictionary *theUserInfo = [NSMutableDictionary dictionary];
                if (request != NULL)
                    {
                    [theUserInfo setObject:request forKey:@"request"];
                    }
                if (response != NULL)
                    {
                    [theUserInfo setObject:response forKey:@"response"];
                    }
                if (data != NULL)
                    {
                    [theUserInfo setObject:data forKey:@"data"];
                    }
                [theUserInfo setObject:response forKey:@"response"];
                
                
                NSError *theError = [NSError errorWithDomain:@"HTTP_DOMAIN" code:theHTTPResponse.statusCode userInfo:theUserInfo];

                handler(NULL, NULL, theError);
                theHandledFlag = YES;
                }

            }

        if (theHandledFlag == NO)
            {
            handler(response, data, error);
            }

        self.connectionCount -= 1;
                
        if (inShouldBackground)
            {
            [[UIApplication sharedApplication] endBackgroundTask:theBackgroundTaskIdentifier];
            }
        
        
//        double delayInSeconds = 30.0;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (dispatch_time_t)(delayInSeconds * NSEC_PER_SEC));
//        LogDebug_(@"Started");
//        dispatch_after(popTime, dispatch_get_main_queue(),^{
//            theBlock();
//            LogDebug_(@"Finished");
//            });

        }];

    }


@end
