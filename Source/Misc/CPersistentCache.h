//
//  CPersistentCache.h
//  PDFReader
//
//  Created by Jonathan Wight on 06/02/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPersistentCache : NSObject

@property (readonly, nonatomic, retain) NSString *name;

+ (CPersistentCache *)persistentCacheWithName:(NSString *)inName;

- (id)initWithName:(NSString *)inName;

- (BOOL)containsObjectForKey:(id)inKey;
- (id)objectForKey:(id)inKey;
- (void)setObject:(id)inObject forKey:(id)inKey;
- (void)setObject:(id)inObject forKey:(id)inKey cost:(NSUInteger)inCost;
- (void)removeObjectForKey:(id)inKey;

@end

#pragma mark -

typedef void (^CacheBlock)(id result, NSError *error);

@interface CPersistentCache (CPersistentCache_ConvenienceExtensions)

- (id)cachedCalculation:(id (^)(void))inBlock forKey:(id)inKey;

- (CacheBlock)asyncCachedCalculation:(CacheBlock)inBlock forKey:(id)inKey;

@end