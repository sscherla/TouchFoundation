//
//  NSSet_Extensions.m
//  SetTest
//
//  Created by Jonathan Wight on 1/27/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "NSSet_Extensions.h"

@implementation NSSet (NSSet_Extensions)

- (NSSet *)setByRemovingObjectsInSet:(NSSet *)inSet
    {
    NSMutableSet *theSet = [self mutableCopy];
    [theSet minusSet:inSet];
    return([theSet copy]);
    }

+ (NSSet *)setWithIntersectionOfSets:(NSSet *)inSet, ...
    {
    NSMutableSet *theFinalSet = [inSet mutableCopy];
    
    va_list ap;
    NSSet *theSet = NULL;

    va_start(ap, inSet); 
    for (theSet = va_arg(ap, NSSet *); theSet != NULL; theSet = va_arg(ap, NSSet *))
        {
        [theFinalSet intersectSet:theSet];
        }
    va_end(ap);

    return([theFinalSet copy]);
    }

@end
