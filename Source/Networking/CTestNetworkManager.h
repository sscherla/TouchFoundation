//
//  CTestNetworkManager.h
//  toxicsoftware.com
//
//  Created by Jonathan Wight on 9/30/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CNetworkManager.h"

@interface CTestNetworkManager : CNetworkManager

@property (readwrite, nonatomic, assign) NSUInteger successCount;
@property (readwrite, nonatomic, assign) float failureRate;

@end
