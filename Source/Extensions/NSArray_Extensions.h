//
//  NSArray_Extensions.h
//  //  TouchFoundation
//
//  Created by j Wight on 8/4/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NSArray_Extensions)

/// If NSEnumerationConcurrent is used, order of mapped array is undefined.
- (NSArray *)mapObjectsWithOptions:(NSEnumerationOptions)inEnumerationOptions usingBlock:(id (^)(id obj, NSUInteger idx, BOOL *stop))inBlock;

- (BOOL)isSortedUsingDescriptors:(NSArray *)inSortDescriptors;

- (BOOL)allObjectsAreUnique;

@end
