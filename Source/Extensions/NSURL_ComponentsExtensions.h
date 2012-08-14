//
//  NSURL_ComponentsExtensions.h
//  //  TouchFoundation
//
//  Created by j Wight on 8/4/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (NSURL_ComponentsExtensions)

+ (NSURL *)URLWithScheme:(NSString *)inScheme resourceSpecifier:(NSString *)inResourceSpecifier;
+ (NSURL *)URLWithComponents:(NSDictionary *)inComponents;
+ (NSString *)resourceSpecifierWithComponents:(NSDictionary *)inComponents;
- (NSDictionary *)components;
- (NSURL *)URLByReplacingQuery:(NSString *)inQuery;

@end
