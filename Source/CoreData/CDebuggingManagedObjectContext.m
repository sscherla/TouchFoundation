//
//  CDebuggingManagedObjectContext.m
//  TouchCode
//
//  Created by Jonathan Wight on 11/16/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CDebuggingManagedObjectContext.h"

@interface CDebuggingManagedObjectContext ()
@property (readwrite, nonatomic, retain) NSArray *callStacksForDirtyPerformBlocks;
@end

#pragma mark -

@implementation CDebuggingManagedObjectContext

@synthesize callStacksForDirtyPerformBlocks;

- (void)performBlockAndWait:(void (^)())block
    {
    [super performBlockAndWait:block];

    if ([self hasChanges] == YES)
        {
        NSArray *theCallStack = [NSThread callStackSymbols];
        if (self.callStacksForDirtyPerformBlocks == NULL)
            {
            self.callStacksForDirtyPerformBlocks = [NSArray arrayWithObject:theCallStack];
            }
        else
            {
            self.callStacksForDirtyPerformBlocks = [self.callStacksForDirtyPerformBlocks arrayByAddingObject:theCallStack];
            }
        }
    }
    
- (BOOL)save:(NSError *__autoreleasing *)error
    {
    BOOL theResult = [super save:error];
    
    if (theResult == YES)
        {
        self.callStacksForDirtyPerformBlocks = NULL;
        }
    
    return(theResult);
    }

@end
