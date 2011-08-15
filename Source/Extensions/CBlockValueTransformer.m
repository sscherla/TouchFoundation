//
//  CBlockValueTransformer.m
//  knotes
//
//  Created by Jonathan Wight on 8/10/11.
//  Copyright (c) 2011 knotes. All rights reserved.
//

#import "CBlockValueTransformer.h"

@interface CBlockValueTransformer ()
@property (readwrite, nonatomic, copy) id (^block)(id);
@property (readwrite, nonatomic, copy) id (^reverseBlock)(id);
@end

@implementation CBlockValueTransformer

@synthesize block;
@synthesize reverseBlock;
    
- (id)initWithBlock:(id (^)(id))inBlock reverseBlock:(id (^)(id))inReverseBlock;
    {
    if ((self = [super init]) != NULL)
        {
        block = inBlock;
        reverseBlock = inReverseBlock;
        }
    return self;
    }

- (id)initWithBlock:(id (^)(id))inBlock;
    {
    if ((self = [self initWithBlock:inBlock reverseBlock:NULL]) != NULL)
        {
        }
    return self;
    }

- (id)transformedValue:(id)value
    {
    return(self.block(value));
    }
    
- (id)reverseTransformedValue:(id)value
    {
    return(self.reverseBlock(value));
    }

@end
