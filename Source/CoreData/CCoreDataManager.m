//
//  CCoreDataManager.m
//  //  TouchFoundation
//
//  Created by j Wight on 8/4/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//

#import "CCoreDataManager.h"

#import <CoreData/CoreData.h>

#import "CDebuggingManagedObjectContext.h"
#import "NSManagedObjectContext_Extensions.h"

@interface CCoreDataManager ()

@property (readwrite, nonatomic, strong) NSURL *modelURL;
@property (readwrite, nonatomic, strong) NSURL *persistentStoreURL;
@property (readwrite, nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (readwrite, nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readwrite, nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

#pragma mark -

@implementation CCoreDataManager

@synthesize persistentStoreURL;
@synthesize persistentStoreOptions;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;
@synthesize managedObjectContextClass;
@synthesize managedObjectContext;

- (id)initWithApplicationDefaults;
    {
    NSBundle *theBundle = [NSBundle mainBundle];
    NSString *theBundleName = [theBundle infoDictionary][(__bridge NSString *)kCFBundleNameKey];
    // TODO - we should search for all .momd and .mom files and combine them perhaps?
    NSURL *theModelURL = [theBundle URLForResource:theBundleName withExtension:@"momd"];

    NSError *theError = NULL;
    NSURL *theApplicationSupportDirectory = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:NULL create:YES error:&theError];

    theApplicationSupportDirectory = [theApplicationSupportDirectory URLByAppendingPathComponent:theBundle.bundleIdentifier];
    [[NSFileManager defaultManager] createDirectoryAtURL:theApplicationSupportDirectory withIntermediateDirectories:YES attributes:NULL error:&theError];

    NSURL *thePersistentStoreURL = [[theApplicationSupportDirectory URLByAppendingPathComponent:theBundleName] URLByAppendingPathExtension:@"sqlite"];

    if ((self = [self initWithModelURL:theModelURL persistentStoreURL:thePersistentStoreURL]) != NULL)
        {
        }
    return self;
    }



- (id)initWithModelURL:(NSURL *)inModelURL persistentStoreURL:(NSURL *)inPersistentStoreURL
    {
    if ((self = [super init]) != NULL)
        {
        _modelURL = inModelURL;
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
		if (managedObjectModel == NULL)
			{
			self = NULL;
			return(NULL);
			}
        persistentStoreURL = inPersistentStoreURL;
        managedObjectContextClass = [NSManagedObjectContext class];
        #if DEBUG == 1
        managedObjectContextClass = [CDebuggingManagedObjectContext class];
        #endif
        persistentStoreOptions = @{
            NSMigratePersistentStoresAutomaticallyOption : @(YES),
            NSInferMappingModelAutomaticallyOption : @(YES),
            };
        }
    return self;
    }

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
    {
    if (persistentStoreCoordinator == NULL)
        {
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSError *theError = NULL;
        NSPersistentStore *thePersistentStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:NULL URL:self.persistentStoreURL options:self.persistentStoreOptions error:&theError];
        if (thePersistentStore == NULL)
            {
            NSLog(@"Error: %@", theError);
            }
        }
    return(persistentStoreCoordinator);
    }

- (NSManagedObjectContext *)managedObjectContext
    {
    if (managedObjectContext == NULL)
        {
        managedObjectContext = [[self.managedObjectContextClass alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        #if DEBUG == 1
        managedObjectContext.debugName = @"main";
        #endif
        [managedObjectContext performBlockAndWait:^{
            managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
            }];
        }
    return(managedObjectContext);
    }



@end
