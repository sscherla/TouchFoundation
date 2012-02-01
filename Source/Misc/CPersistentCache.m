//
//  CPersistentCache.m
//  TouchCode
//
//  Created by Jonathan Wight on 06/02/11.
//	Copyright 2011 toxicsoftware.com. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	   1. Redistributions of source code must retain the above copyright notice, this list of
//	      conditions and the following disclaimer.
//
//	   2. Redistributions in binary form must reproduce the above copyright notice, this list
//	      of conditions and the following disclaimer in the documentation and/or other materials
//	      provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL TOXICSOFTWARE.COM OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of toxicsoftware.com.

#import "CPersistentCache.h"

#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#endif /* TARGET_OS_IPHONE */

#import "NSData_Extensions.h"
#import "NSData_DigestExtensions.h"
#import "CTypedData.h"
#import "NSNumber_Extensions.h"

#define STORE_STATISTICS 1

@interface CPersistentCache ()
@property (readwrite, nonatomic, strong) NSURL *URL;
@property (readonly, nonatomic, strong) NSURL *dataDirectoryURL;
@property (readonly, nonatomic, strong) NSURL *metadataDirectoryURL;
@property (readwrite, nonatomic, strong) NSValueTransformer *keyTransformer;
@property (readwrite, nonatomic, strong) NSCache *objectCache;
@property (readwrite, nonatomic, assign) dispatch_queue_t queue;
@property (readwrite, nonatomic, assign) id applicationWillTerminateNotification;
#if STORE_STATISTICS == 1
@property (readwrite, nonatomic, assign) NSUInteger cacheHits;
@property (readwrite, nonatomic, assign) NSUInteger cacheMisses;
@property (readwrite, nonatomic, assign) NSUInteger totalCost;
#endif /* STORE_STATISTICS == 1 */

- (void)shutdown;
- (void)setCacheMetadataNeedUpdate;
- (void)updateCacheMetadata;
- (void)loadCacheMetadata;
- (void)purge;
- (NSDictionary *)metadataForKey:(id)inKey;
- (NSString *)pathComponentForKey:(id)inKey;
- (NSURL *)URLForMetadataForKey:(id)inKey;
@end

#pragma mark -

@implementation CPersistentCache

@synthesize name;
@synthesize version;
@synthesize diskWritesEnabled;
@synthesize maximumAge;

@synthesize URL;
@synthesize keyTransformer;
@synthesize objectCache;
@synthesize queue;
@synthesize applicationWillTerminateNotification;

#if STORE_STATISTICS == 1
@synthesize cacheHits;
@synthesize cacheMisses;
@synthesize totalCost;
#endif /* STORE_STATISTICS == 1 */

static dispatch_queue_t sQueue = NULL;
static NSMutableDictionary *sNamedPersistentCaches = NULL;

+ (CPersistentCache *)persistentCacheWithName:(NSString *)inName
    {
    static dispatch_once_t sOnceToken = 0;
    dispatch_once(&sOnceToken, ^{
        sQueue = dispatch_queue_create(".CPersistentCache", 0);
        sNamedPersistentCaches = [[NSMutableDictionary alloc] init];
        });

    __block CPersistentCache *theCache = NULL;
    dispatch_sync(sQueue, ^() {
        theCache = [sNamedPersistentCaches objectForKey:inName];
        if (theCache == NULL)
            {
            theCache = [[self alloc] initWithName:inName];
            [sNamedPersistentCaches setObject:theCache forKey:inName];
            }
        });

    return(theCache);
    }

- (id)initWithName:(NSString *)inName
	{
	if ((self = [self init]) != NULL)
		{
        NSParameterAssert(inName.length > 0);
        name = inName;
        version = @"0";
        maximumAge = 0;
        diskWritesEnabled = YES;
        keyTransformer = [NSValueTransformer valueTransformerForName:NSKeyedUnarchiveFromDataTransformerName];
        objectCache = [[NSCache alloc] init];
        #if 1
        NSString *theQueueName = [NSString stringWithFormat:@"org.touchcode.CPersistentCache.%@", inName];
        queue = dispatch_queue_create([theQueueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
        #else
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_retain(queue);
        #endif
        
        [self loadCacheMetadata];
        
        #if TARGET_OS_IPHONE == 1
        __weak CPersistentCache *_self = self;
        applicationWillTerminateNotification = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication] queue:NULL usingBlock:^(NSNotification *note) {
            [_self shutdown];
            }];
        #endif /* TARGET_OS_IPHONE == 1 */
        }
	return(self);
	}

- (void)dealloc
    {
    [self shutdown];
    
    dispatch_release(queue);
    queue = NULL;
    }

- (NSURL *)URL
    {
    if (URL == NULL)
        {
        NSURL *theURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        theURL = [theURL URLByAppendingPathComponent:@"PersistentCache"];
        theURL = [theURL URLByAppendingPathComponent:self.name];
        theURL = [theURL URLByAppendingPathComponent:self.version];
        if ([[NSFileManager defaultManager] fileExistsAtPath:theURL.path] == NO)
            {
            [[NSFileManager defaultManager] createDirectoryAtPath:theURL.path withIntermediateDirectories:YES attributes:NULL error:NULL];
            }
        URL = theURL;
        }
    return(URL);
    }

- (NSURL *)dataDirectoryURL
    {
    return(self.URL);
    }

- (NSURL *)metadataDirectoryURL
    {
    return(self.URL);
    }

#pragma mark -

- (void)shutdown
    {
    [self purge];
    
    [self updateCacheMetadata];
    }

- (void)setCacheMetadataNeedUpdate
    {
    [self updateCacheMetadata];
    }

- (void)updateCacheMetadata
    {
    dispatch_barrier_async(self.queue, ^(void) {
        NSDictionary *theMetadata = [NSDictionary dictionaryWithObjectsAndKeys:
#if STORE_STATISTICS == 1
            NSNumberWithValue(self.cacheHits), @"cacheHits",
            NSNumberWithValue(self.cacheMisses), @"cacheMisses",
#endif /* STORE_STATISTICS == 1 */
            NSNumberWithValue(self.totalCost), @"totalCost",
            NULL];
        NSURL *theURL = [self.URL URLByAppendingPathComponent:@"metadata.plist"];
        [theMetadata writeToURL:theURL atomically:YES];
        });
    }

- (void)loadCacheMetadata
    {
    dispatch_sync(self.queue, ^(void) {
        NSURL *theURL = [self.URL URLByAppendingPathComponent:@"metadata.plist"];
        NSDictionary *theMetadata = [NSDictionary dictionaryWithContentsOfURL:theURL];
        self.cacheHits = [[theMetadata objectForKey:@"cacheHits"] unsignedIntegerValue];
        self.cacheMisses = [[theMetadata objectForKey:@"cacheMisses"] unsignedIntegerValue];
        self.totalCost = [[theMetadata objectForKey:@"totalCost"] unsignedIntegerValue];
        });
    }

- (void)purge
    {
    dispatch_barrier_sync(self.queue, ^(void) {

        if (self.maximumAge <= 0)
            {
            return;
            }

        NSUInteger thePurgeCount = 0;
        NSUInteger theNotPurgeCount = 0;

        NSDate *theNow = [NSDate date];
        
        NSFileManager *theFileManager = [[NSFileManager alloc] init];
        NSDirectoryEnumerator *theEnumerator = [theFileManager enumeratorAtURL:self.metadataDirectoryURL includingPropertiesForKeys:NULL options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles errorHandler:NULL];
        for (NSURL *theMetadataURL in theEnumerator)
            {
            if ([[[theMetadataURL.path stringByDeletingPathExtension] pathExtension] isEqualToString:@"metadata"])
                {
                NSDictionary *theMetadata = [NSDictionary dictionaryWithContentsOfURL:theMetadataURL];
                NSDate *theDate = [theMetadata objectForKey:@"accessed"];
                if ([theNow timeIntervalSinceDate:theDate] > self.maximumAge)
                    {
                    thePurgeCount++;

                    NSURL *theDataURL = [self.dataDirectoryURL URLByAppendingPathComponent:[theMetadata objectForKey:@"href"]];
                    NSError *theError = NULL;
                    if ([theFileManager removeItemAtURL:theDataURL error:&theError] == NO)
                        {
                        }
                        
                    if ([theFileManager removeItemAtURL:theMetadataURL error:&theError] == NO)
                        {
                        }
                    
                    }
                else
                    {
                    theNotPurgeCount += 1;
                    }
                }
            }
            
//        LogInfo_(@"Purged %d, skipped %d", thePurgeCount, theNotPurgeCount);
        });
    }

#pragma mark -

- (NSString *)pathComponentForKey:(id)inKey
    {
    NSData *theData = [self.keyTransformer reverseTransformedValue:inKey];
    return([[theData MD5Digest] hexString]);
    }

- (NSURL *)URLForMetadataForKey:(id)inKey
    {
    NSURL *theMetadataURL = [[self.metadataDirectoryURL URLByAppendingPathComponent:[self pathComponentForKey:inKey]] URLByAppendingPathExtension:@"metadata.plist"];
    return(theMetadataURL);
    }

- (NSDictionary *)metadataForKey:(id)inKey;
    {
    NSURL *theMetadataURL = [self URLForMetadataForKey:inKey];
    NSDictionary *theMetadata = [NSDictionary dictionaryWithContentsOfURL:theMetadataURL];
    return(theMetadata);
    }

- (BOOL)containsObjectForKey:(id)inKey
    {
    if ([self.objectCache objectForKey:inKey] != NULL)
        {
        return(YES);
        }

    NSURL *theMetadataURL = [self URLForMetadataForKey:inKey];
    if ([[NSFileManager defaultManager] fileExistsAtPath:theMetadataURL.path] == YES)
        {
        return(YES);
        }
    return(NO);
    }

- (id)objectForKey:(id)inKey
    {
    __block id theObject = NULL;
    
    dispatch_sync(self.queue, ^(void) {
    
        theObject = [self.objectCache objectForKey:inKey];
        if (theObject != NULL)
            {
            #if STORE_STATISTICS == 1
            self.cacheHits++;
            #endif /* STORE_STATISTICS == 1 */
            }
        else
            {
            #if STORE_STATISTICS == 1
            self.cacheMisses++;
            #endif /* STORE_STATISTICS == 1 */

            NSData *theData = NULL;
            NSDictionary *theMetadata = [self metadataForKey:inKey];
            if (theMetadata != NULL)
                {
                NSURL *theDataURL = [self.dataDirectoryURL URLByAppendingPathComponent:[theMetadata objectForKey:@"href"]];
                theData = [NSData dataWithContentsOfURL:theDataURL options:NSDataReadingMapped error:NULL];
                
                if (self.diskWritesEnabled == YES)
                    {
                    dispatch_barrier_async(self.queue, ^(void) {
                        NSMutableDictionary *theMutableMetadata = [theMetadata mutableCopy];
                        [theMutableMetadata setObject:[NSDate date] forKey:@"accessed"];
                        NSUInteger theAccessCount = [[theMutableMetadata objectForKey:@"accessCount"] unsignedIntegerValue];
                        [theMutableMetadata setObject:[NSNumber numberWithUnsignedLong:theAccessCount + 1] forKey:@"accessCount"];
                        NSError *theError = NULL;
                        NSData *theData = [NSPropertyListSerialization dataWithPropertyList:theMutableMetadata format:NSPropertyListBinaryFormat_v1_0 options:0 error:&theError];
                        [theError log:@"CPersistentCache: Converting metadata to binary plist"];
                        [theData writeToURL:[self URLForMetadataForKey:inKey] options:0 error:&theError];
                        });
                    }
                }

            if (theData)
                {
                NSString *theType = [theMetadata objectForKey:@"type"];
                CTypedData *theTypedData = [[CTypedData alloc] initWithType:theType data:theData metadata:theMetadata];
                theObject = [theTypedData transformedObject];

                NSUInteger theCost = [theData length];

                [self.objectCache setObject:theObject forKey:inKey cost:theCost];
                }
            }
            
        #if STORE_STATISTICS == 1
        [self setCacheMetadataNeedUpdate];
        #endif /* STORE_STATISTICS == 1 */
        });

    return(theObject);
    }

- (void)setObject:(id)inObject forKey:(id)inKey
    {
    [self setObject:inObject forKey:inKey cost:0];
    }

- (void)setObject:(id)inObject forKey:(id)inKey cost:(NSUInteger)inCost
    {
    dispatch_barrier_async(self.queue, ^(void) {
        CTypedData *theTypedData = [[CTypedData alloc] initByTransformingObject:inObject];
        NSParameterAssert(theTypedData != NULL);

        const NSUInteger theCost = inCost ?: [theTypedData.data length];

        [self.objectCache setObject:inObject forKey:inKey cost:theCost];

        if (self.diskWritesEnabled == YES)
            {
            NSURL *theURL = [self.dataDirectoryURL URLByAppendingPathComponent:[self pathComponentForKey:inKey]];

            // Generate the data URL...
            NSURL *theDataURL = theURL;
            NSString *theFilenameExtension = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)theTypedData.type, kUTTagClassFilenameExtension);
            if (theFilenameExtension)
                {
                theDataURL = [theDataURL URLByAppendingPathExtension:theFilenameExtension];
                }

            NSDate *theDateNow = [NSDate date];

            // Generate the metadata...
            NSMutableDictionary *theMetadata = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                [theDataURL lastPathComponent], @"href",
                [NSNumber numberWithUnsignedInteger:theCost], @"cost",
                theTypedData.type, @"type",
                [self.keyTransformer reverseTransformedValue:inKey], @"key",
                theDateNow, @"created",
                theDateNow, @"accessed",
    #if DEBUG == 1
                [inKey description], @"key_description",
    #endif
                NULL];
            if (theTypedData.metadata != NULL)
                {
                [theMetadata addEntriesFromDictionary:theTypedData.metadata];
                }
            NSParameterAssert(theTypedData.data != NULL);

            NSError *theError = NULL;
            [theTypedData.data writeToURL:theDataURL options:0 error:&theError];
            [theError log:@"CPersistentCache: Writing cache data to disk"];

            NSData *theData = [NSPropertyListSerialization dataWithPropertyList:theMetadata format:NSPropertyListBinaryFormat_v1_0 options:0 error:&theError];
            [theError log:@"CPersistentCache: Converting metadata to binary plist"];
            [theData writeToURL:[theURL URLByAppendingPathExtension:@"metadata.plist"] options:0 error:&theError];

            self.totalCost += theCost;
            
            [self setCacheMetadataNeedUpdate];
            }
        });
    }

- (void)removeObjectForKey:(id)inKey
    {
    dispatch_barrier_async(self.queue, ^(void) {

        if ([self.objectCache objectForKey:inKey])
            {
            [self.objectCache removeObjectForKey:inKey];
            }

        NSDictionary *theMetadata = [self metadataForKey:inKey];
        if (theMetadata != NULL)
            {
            NSError *theError = NULL;

            NSURL *theMetadataURL = [self URLForMetadataForKey:inKey];
            [[NSFileManager defaultManager] removeItemAtURL:theMetadataURL error:&theError];

            NSURL *theDataURL = [self.dataDirectoryURL URLByAppendingPathComponent:[theMetadata objectForKey:@"href"]];
            [[NSFileManager defaultManager] removeItemAtURL:theDataURL error:&theError];

            NSUInteger theCost = [[theMetadata objectForKey:@"cost"] unsignedIntegerValue];
            self.totalCost -= theCost;
            [self setCacheMetadataNeedUpdate];
            }
        });
    }

@end

#pragma mark -

@implementation CPersistentCache (CPersistentCache_ConvenienceExtensions)

- (id)cachedCalculation:(id (^)(void))inBlock forKey:(id)inKey
    {
    id theObject = NULL;
    if (inKey == NULL)
        {
        theObject = inBlock();
        }
    else
        {
        theObject = [self objectForKey:inKey];
        if (theObject == NULL)
            {
            theObject = inBlock();
            if (theObject != NULL)
                {
                [self setObject:theObject forKey:inKey];
                }
            }
        }
    return(theObject);
    }

- (CacheBlock)asyncCachedCalculation:(CacheBlock)inBlock forKey:(id)inKey;
    {
    id theResult = [self objectForKey:inKey];
    if (theResult)
        {
        inBlock(theResult, NULL);
        return(NULL);
        }
    else
        {
        CacheBlock theBlock = ^(id inResult, NSError *inError)
            {
            if (inResult)
                {
                [self setObject:inResult forKey:inKey];
                }

            inBlock(inResult, inError);
            };
        return(theBlock);
        }
    }

@end



