//
//  NSArray_Extensions.m
//  //  TouchFoundation
//
//  Created by j Wight on 8/4/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//

#import "NSArray_Extensions.h"

@implementation NSArray (NSArray_Extensions)

- (NSArray *)mapObjectsWithOptions:(NSEnumerationOptions)inEnumerationOptions usingBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))inBlock
    {
    NSMutableArray *theMappedArray = [NSMutableArray array];
    
    [self enumerateObjectsWithOptions:inEnumerationOptions usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BOOL theStopFlag = NO;
        id theMappedObject = inBlock(obj, idx, &theStopFlag);
        if (theStopFlag == YES)
            {
            *stop = YES;
            }
        else
            {
            [theMappedArray addObject:theMappedObject];
            }
        }];
    
    return(theMappedArray);
    }


- (BOOL)isSortedUsingDescriptors:(NSArray *)inSortDescriptors
    {
    if (self.count == 1)
        return(YES);
    
    id theLastObject = NULL;
    
    for (id theObject in self)
        {
        if (theLastObject)
            {
            for (NSSortDescriptor *theDescriptor in inSortDescriptors)
                {
                NSComparisonResult theResult = [theDescriptor compareObject:theLastObject toObject:theObject];
                if (theResult == NSOrderedDescending)
                    return(NO);
                }
            }
        theLastObject = theObject;
        }
    return(YES);
    }

- (BOOL)allObjectsAreUnique
    {
    return(self.count == [[NSSet setWithArray:self] count]);
    }

@end
