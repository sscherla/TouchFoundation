//
//  NSObject_KVOBlock.h
//  MOO
//
//  Created by Jonathan Wight on 07/24/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KVOBlock)(NSString *keyPath, id object, NSDictionary *change);

@interface NSObject (NSObject_KVOBlock)

- (id)addKVOBlock:(KVOBlock)inBlock forKeyPath:(NSString *)inKeyPath options:(NSUInteger)inOptions;
- (id)addKVOBlock:(KVOBlock)inBlock forKeyPath:(NSString *)inKeyPath options:(NSUInteger)inOptions identifier:(NSString *)inIdentifier;

- (void)removeKVOBlockForToken:(id)inToken;
- (void)removeKVOBlockForKeyPath:(NSString *)inKeyPath identifier:(NSString *)inIdentifier;

- (NSArray *)allKVOObservers;

@end
