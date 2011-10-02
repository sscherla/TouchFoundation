//
//  CJSONValueTransformer.m
//  toxicsoftware.com
//
//  Created by Jonathan Wight on 9/6/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CJSONValueTransformer.h"

@implementation CJSONValueTransformer

+ (void)load
    {
    [self setValueTransformer:[[CJSONValueTransformer alloc] init] forName:@"JSONValueTransformer"];
    }

+ (BOOL)allowsReverseTransformation
    {
    return(YES);
    }

- (id)transformedValue:(id)value
    {
    return([NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:NULL]);
    }

- (id)reverseTransformedValue:(id)value
    {
    return([NSJSONSerialization JSONObjectWithData:value options:0 error:NULL]);
    }

@end
