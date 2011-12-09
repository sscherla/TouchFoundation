//
//  NSNumber_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 12/8/11.
//  Copyright (c) 2011 TouchCode. All rights reserved.
//

#import "NSNumber_Extensions.h"

__attribute__((overloadable)) NSNumber *NSNumberWithValue(char inValue)
    {
    return([NSNumber numberWithChar:inValue]);
    }

__attribute__((overloadable)) NSNumber *NSNumberWithValue(unsigned char inValue)
    {
    return([NSNumber numberWithUnsignedChar:inValue]);
    }

__attribute__((overloadable)) NSNumber *NSNumberWithValue(short inValue)
    {
    return([NSNumber numberWithShort:inValue]);
    }

__attribute__((overloadable)) NSNumber *NSNumberWithValue(unsigned short inValue)
    {
    return([NSNumber numberWithUnsignedShort:inValue]);
    }

__attribute__((overloadable)) NSNumber *NSNumberWithValue(int inValue)
    {
    return([NSNumber numberWithInt:inValue]);
    }

__attribute__((overloadable)) NSNumber *NSNumberWithValue(unsigned int inValue)
    {
    return([NSNumber numberWithUnsignedInt:inValue]);
    }

__attribute__((overloadable)) NSNumber *NSNumberWithValue(long inValue)
    {
    return([NSNumber numberWithLong:inValue]);
    }

__attribute__((overloadable)) NSNumber *NSNumberWithValue(unsigned long inValue)
    {
    return([NSNumber numberWithUnsignedLong:inValue]);
    }

__attribute__((overloadable)) NSNumber *NSNumberWithValue(long long inValue)
    {
    return([NSNumber numberWithLongLong:inValue]);
    }

__attribute__((overloadable)) NSNumber *NSNumberWithValue(unsigned long long inValue)
    {
    return([NSNumber numberWithUnsignedLongLong:inValue]);
    }

__attribute__((overloadable)) NSNumber *NSNumberWithValue(float inValue)
    {
    return([NSNumber numberWithFloat:inValue]);
    }

__attribute__((overloadable)) NSNumber *NSNumberWithValue(double inValue)
    {
    return([NSNumber numberWithDouble:inValue]);
    }

__attribute__((overloadable)) NSNumber *NSNumberWithValue(BOOL inValue)
    {
    return([NSNumber numberWithBool:inValue]);
    }

// No NSInteger or NSUInteger versions because these are identical to int/unsigned int or long/unsigned long (and the compiler will complain).
//__attribute__((overloadable)) NSNumber *NSNumberWithValue(NSInteger inValue)
//    {
//    return([NSNumber numberWithInteger:inValue]);
//    }
//
//__attribute__((overloadable)) NSNumber *NSNumberWithValue(NSUInteger inValue)
//    {
//    return([NSNumber numberWithUnsignedInteger:inValue]);
//    }
