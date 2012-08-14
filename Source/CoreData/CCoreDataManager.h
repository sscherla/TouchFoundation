//
//  CCoreDataManager.h
//  TouchFoundation
//
//  Created by j Wight on 8/4/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@interface CCoreDataManager : NSObject

@property (readonly, nonatomic, strong) NSURL *persistentStoreURL;
@property (readwrite, nonatomic, strong) NSDictionary *persistentStoreOptions;
@property (readonly, nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (readonly, nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, nonatomic, strong) Class managedObjectContextClass;
@property (readonly, nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (id)initWithModelURL:(NSURL *)inModelURL PersistentStoreURL:(NSURL *)inPersistentStoreURL;

- (BOOL)prepare:(NSError **)outError;

@end
