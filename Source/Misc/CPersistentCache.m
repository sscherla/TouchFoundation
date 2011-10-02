//
//  CPersistentCache.m
//  PDFReader
//
//  Created by Jonathan Wight on 06/02/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import "CPersistentCache.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "NSData_Extensions.h"
#import "NSData_DigestExtensions.h"
#import "CTypedData.h"

#define CACHE_VERSION 0

@interface CPersistentCache ()
@property (readwrite, nonatomic, retain) NSURL *URL;
@property (readwrite, nonatomic, retain) NSValueTransformer *keyTransformer;
@property (readwrite, nonatomic, retain) NSCache *objectCache;

- (NSDictionary *)metadataForKey:(id)inKey;
- (NSString *)pathComponentForKey:(id)inKey;
- (NSURL *)URLForMetadataForKey:(id)inKey;
@end

#pragma mark -

@implementation CPersistentCache

@synthesize name;

@synthesize URL;
@synthesize keyTransformer;
@synthesize objectCache;

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
	if ((self = [super init]) != NULL)
		{
        name = inName;
        keyTransformer = [NSValueTransformer valueTransformerForName:NSKeyedUnarchiveFromDataTransformerName];
        objectCache = [[NSCache alloc] init];
		}
	return(self);
	}
    
- (NSURL *)URL
    {
    if (URL == NULL)
        {
        NSURL *theURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        theURL = [theURL URLByAppendingPathComponent:@"PersistentCache"];
        theURL = [theURL URLByAppendingPathComponent:[NSString stringWithFormat:@"V%d", CACHE_VERSION]];
        theURL = [theURL URLByAppendingPathComponent:self.name];
        if ([[NSFileManager defaultManager] fileExistsAtPath:theURL.path] == NO)
            {
            [[NSFileManager defaultManager] createDirectoryAtPath:theURL.path withIntermediateDirectories:YES attributes:NULL error:NULL];
            }
        URL = theURL;
        }
    return(URL);
    }
    
#pragma mark -

- (NSString *)pathComponentForKey:(id)inKey
    {
    NSData *theData = [self.keyTransformer reverseTransformedValue:inKey];
    return([[theData MD5Digest] hexString]);
    }

- (NSURL *)URLForMetadataForKey:(id)inKey
    {
    NSURL *theMetadataURL = [[self.URL URLByAppendingPathComponent:[self pathComponentForKey:inKey]] URLByAppendingPathExtension:@"metadata.plist"];
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
    id theObject = [self.objectCache objectForKey:inKey];
    if (theObject == NULL)
        {
        NSData *theData = NULL;
        NSDictionary *theMetadata = [self metadataForKey:inKey];
        if (theMetadata != NULL)
            {
            NSURL *theDataURL = [self.URL URLByAppendingPathComponent:[theMetadata objectForKey:@"href"]];
            theData = [NSData dataWithContentsOfURL:theDataURL options:NSDataReadingMapped error:NULL];
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

//    if (theObject == NULL)
//        {
//        NSLog(@"CACHE MISS: %@", inKey);
//        }
        
    return(theObject);
    }
    
- (void)setObject:(id)inObject forKey:(id)inKey
    {
    [self setObject:inObject forKey:inKey cost:0];
    }
    
- (void)setObject:(id)inObject forKey:(id)inKey cost:(NSUInteger)inCost
    {
    CTypedData *theTypedData = [[CTypedData alloc] initByTransformingObject:inObject];
    NSParameterAssert(theTypedData != NULL);
    
    if (inCost == 0)
        {
        inCost = [theTypedData.data length];
        }

    NSURL *theURL = [self.URL URLByAppendingPathComponent:[self pathComponentForKey:inKey]];

    [self.objectCache setObject:inObject forKey:inKey cost:inCost];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {

        NSError *theError = NULL;
        
        NSURL *theDataURL = theURL;
        NSString *theFilenameExtension = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)theTypedData.type, kUTTagClassFilenameExtension);
        if (theFilenameExtension)
            {
            theDataURL = [theDataURL URLByAppendingPathExtension:theFilenameExtension];
            }
    
        NSParameterAssert(theTypedData.data != NULL);
        [theTypedData.data writeToURL:theDataURL options:0 error:&theError];
        // TODO:error checking.

        NSMutableDictionary *theMetadata = [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [theDataURL lastPathComponent], @"href",
            [NSNumber numberWithUnsignedInteger:inCost], @"cost",
            theTypedData.type, @"type",
            [self.keyTransformer reverseTransformedValue:inKey], @"key",
#if DEBUG == 1
            [inKey description], @"key_description",
#endif            
            NULL];
        
        if (theTypedData.metadata != NULL)
            {
            [theMetadata addEntriesFromDictionary:theTypedData.metadata];
            }
        

        NSData *theData = [NSPropertyListSerialization dataWithPropertyList:theMetadata format:NSPropertyListBinaryFormat_v1_0 options:0 error:&theError];
        // TODO:error checking.
        [theData writeToURL:[theURL URLByAppendingPathExtension:@"metadata.plist"] options:0 error:&theError];
        // TODO:error checking.
        });
    }

- (void)removeObjectForKey:(id)inKey
    {
    if ([self.objectCache objectForKey:inKey])
        {
        [self.objectCache removeObjectForKey:inKey];
        }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        NSDictionary *theMetadata = [self metadataForKey:inKey];
        if (theMetadata != NULL)
            {
            NSError *theError = NULL;

            NSURL *theMetadataURL = [self URLForMetadataForKey:inKey];
            [[NSFileManager defaultManager] removeItemAtURL:theMetadataURL error:&theError];

            NSURL *theDataURL = [self.URL URLByAppendingPathComponent:[theMetadata objectForKey:@"href"]];
            [[NSFileManager defaultManager] removeItemAtURL:theDataURL error:&theError];
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



