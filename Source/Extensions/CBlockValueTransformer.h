//
//  CBlockValueTransformer.h
//  knotes
//
//  Created by Jonathan Wight on 8/10/11.
//  Copyright (c) 2011 knotes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBlockValueTransformer : NSValueTransformer

- (id)initWithBlock:(id (^)(id))inBlock reverseBlock:(id (^)(id))inReverseBlock;
- (id)initWithBlock:(id (^)(id))inBlock;

@end
