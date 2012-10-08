//
//  CArrayMergeHelper.m
//  Jonathan Wight
//
//  Created by Jonathan Wight on 8/5/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//

#import "CArrayMergeHelper.h"

#import "NSArray_Extensions.h"

@implementation CArrayMergeHelper

@synthesize leftArray;
@synthesize leftKey;
@synthesize rightArray;
@synthesize rightKey;
@synthesize insertHandler;
@synthesize updateHandler;

- (NSArray *)merge:(NSError **)outError
    {
    NSParameterAssert(self.leftArray != NULL);
    NSParameterAssert(self.leftKey != NULL);
    NSParameterAssert(self.rightArray != NULL);
    NSParameterAssert(self.rightKey != NULL);
    NSParameterAssert([self.leftArray isSortedUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:self.leftKey ascending:YES]]]);
    NSParameterAssert([self.rightArray isSortedUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:self.rightKey ascending:YES]]]);
    NSParameterAssert([self.leftArray allObjectsAreUnique]);
    NSParameterAssert([self.rightArray allObjectsAreUnique]);
    
    NSMutableArray *theMergedObjects = [NSMutableArray array];

    NSEnumerator *theLeftArrayEnumerator = [self.leftArray objectEnumerator];
    id theLeftObject = [theLeftArrayEnumerator nextObject];

    NSEnumerator *theRightArrayEnumerator = [self.rightArray objectEnumerator];
    id theRightObject = [theRightArrayEnumerator nextObject];


    while (theLeftObject != NULL || theRightObject != NULL)
        {
        NSComparisonResult theComparisonResult = NSOrderedAscending;

        id theLeftSortValue = [theLeftObject valueForKey:self.leftKey];
        id theRightSortValue = [theRightObject valueForKey:self.rightKey];

        if (theLeftSortValue == NULL)
            {
            theComparisonResult = NSOrderedDescending;
            }
        else if (theRightSortValue == NULL)
            {
            theComparisonResult = NSOrderedAscending;
            }
        else
            {
            theComparisonResult = [theLeftSortValue compare:theRightSortValue];
            }

        id theMergedObject = NULL;
        if (theComparisonResult == NSOrderedAscending)
            {
            theMergedObject = theLeftObject;
            theLeftObject = [theLeftArrayEnumerator nextObject];
            }
        else if (theComparisonResult == NSOrderedSame)
            {
            
            if (self.updateHandler == NULL)
                {
                theMergedObject = theLeftObject;
                }
            else
                {
                theMergedObject = self.updateHandler(theLeftObject, theRightObject);
                }
            
            theLeftObject = [theLeftArrayEnumerator nextObject];
            theRightObject = [theRightArrayEnumerator nextObject];
            }
        else if (theComparisonResult == NSOrderedDescending)
            {
            if (self.insertHandler == NULL)
                {
                // TODO should probably assert here - returning theRightObject makes no sense.
                theMergedObject = theRightObject;
                }
            else
                {
                theMergedObject = self.insertHandler(theRightObject);
                if (self.updateHandler != NULL)
                    {
                    self.updateHandler(theMergedObject, theRightObject);
                    }
                }

            theRightObject = [theRightArrayEnumerator nextObject];
            }

        [theMergedObjects addObject:theMergedObject];
        }

    NSParameterAssert([theMergedObjects isSortedUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:self.leftKey ascending:YES]]]);
    NSParameterAssert([theMergedObjects allObjectsAreUnique]);

    return(theMergedObjects);
    }

@end
