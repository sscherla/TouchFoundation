//
//  CDebuggingManagedObjectContext.h
//  TouchCode
//
//  Created by Jonathan Wight on 11/16/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import <CoreData/CoreData.h>

/// Use this instead of a normal NSManagedObjectContext. When you modify objects within a context (inside a performBlockAndWait: block) the object stores the call stack. When the context is saved the call stack is cleared. This allows you find out what code left the context in a dirty state.
@interface CDebuggingManagedObjectContext : NSManagedObjectContext

@property (readonly, nonatomic, retain) NSArray *callStacksForDirtyPerformBlocks;

@end
