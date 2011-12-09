//
//  NSNumber_Extensions.h
//  TouchCode
//
//  Created by Jonathan Wight on 12/8/11.
//  Copyright (c) 2011 TouchCode. All rights reserved.
//

#import <Foundation/Foundation.h>

extern __attribute__((overloadable)) NSNumber *NSNumberWithValue(char inValue);
extern __attribute__((overloadable)) NSNumber *NSNumberWithValue(unsigned char inValue);
extern __attribute__((overloadable)) NSNumber *NSNumberWithValue(short inValue);
extern __attribute__((overloadable)) NSNumber *NSNumberWithValue(unsigned short inValue);
extern __attribute__((overloadable)) NSNumber *NSNumberWithValue(int inValue);
extern __attribute__((overloadable)) NSNumber *NSNumberWithValue(unsigned int inValue);
extern __attribute__((overloadable)) NSNumber *NSNumberWithValue(long inValue);
extern __attribute__((overloadable)) NSNumber *NSNumberWithValue(unsigned long inValue);
extern __attribute__((overloadable)) NSNumber *NSNumberWithValue(long long inValue);
extern __attribute__((overloadable)) NSNumber *NSNumberWithValue(unsigned long long inValue);
extern __attribute__((overloadable)) NSNumber *NSNumberWithValue(float inValue);
extern __attribute__((overloadable)) NSNumber *NSNumberWithValue(double inValue);
extern __attribute__((overloadable)) NSNumber *NSNumberWithValue(BOOL inValue);
