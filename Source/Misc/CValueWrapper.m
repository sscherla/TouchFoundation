//
//  CValueWrapper.m
//  toxicsoftware.com
//
//  Created by Jonathan Wight on 9/14/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CValueWrapper.h"

@implementation CValueWrapper

@synthesize value;

- (id)initWithValue:(NSValue *)inValue;
    {
    if ((self = [super init]) != NULL)
        {
        value = inValue;
        }
    return self;
    }

- (void)encodeWithCoder:(NSCoder *)aCoder
    {
    NSUInteger theLength;
    NSGetSizeAndAlignment(self.value.objCType, &theLength, NULL);

    NSMutableData *theData = [NSMutableData dataWithLength:theLength];
    [self.value getValue:theData.mutableBytes];
    
    
    [aCoder encodeObject:theData forKey:@"data"];
    [aCoder encodeObject:[NSString stringWithUTF8String:self.value.objCType] forKey:@"objcType"];
    }
    
- (id)initWithCoder:(NSCoder *)aDecoder
    {
    const char *theType = [[aDecoder decodeObjectForKey:@"objcType"] UTF8String];
    NSData *theData = [aDecoder decodeObjectForKey:@"data"];
    NSValue *theValue = [[NSValue alloc] initWithBytes:theData.bytes objCType:theType];
    if ((self = [super init]) != NULL)
        {
        value = theValue;
        }
    return self;
    }

@end
