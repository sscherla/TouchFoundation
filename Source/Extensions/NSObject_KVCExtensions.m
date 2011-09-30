//
//  NSObject_KVCExtensions.m
//
//  Created by Avi Itskovich on 8/19/11
//  Copyright 2011 Avi Itskovich. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

#import "NSObject_KVCExtensions.h"

#import <objc/runtime.h>

@implementation NSObject (NSObject_KVCExtensions)

// Can set value for key follows the Key Value Settings search pattern as defined
// in the apple documentation
- (BOOL)canSetValueForKey:(NSString *)key {
    // Check if there is a selector based setter
    NSString *capKey = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[key substringToIndex:1] uppercaseString]];
    SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@", capKey]);
    if ([self respondsToSelector:setter]) {
        return YES;
    }

    // If you can access the instance variable directly, check if that exists
    // Patterns for instance variable naming:
    //  1. _<key>
    //  2. _is<Key>
    //  3. <key>
    //  4. is<Key>
    if ([[self class] accessInstanceVariablesDirectly]) {
        // Declare all the patters for the key
        const char *pattern1 = [[NSString stringWithFormat:@"_%@",key] UTF8String];
        const char *pattern2 = [[NSString stringWithFormat:@"_is%@",capKey] UTF8String];
        const char *pattern3 = [[NSString stringWithFormat:@"%@",key] UTF8String];
        const char *pattern4 = [[NSString stringWithFormat:@"is%@",capKey] UTF8String];

        unsigned int numIvars = 0;
        Ivar *ivarList = class_copyIvarList([self class], &numIvars);
        for (unsigned int i = 0; i < numIvars; i++) {
            const char *name = ivar_getName(*ivarList);
            if (strcmp(name, pattern1) == 0 ||
                strcmp(name, pattern2) == 0 ||
                strcmp(name, pattern3) == 0 ||
                strcmp(name, pattern4) == 0) {
                return YES;
            }
            ivarList++;
        }
    }

    return NO;
}

// Traverse the key path finding you can set the values
// Keypath is a set of keys delimited by "."
- (BOOL)canSetValueForKeyPath:(NSString *)keyPath {
    NSRange delimeterRange = [keyPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];

    if (delimeterRange.location == NSNotFound) {
        return [self canSetValueForKey:keyPath];
    }

    NSString *first = [keyPath substringToIndex:delimeterRange.location];
    NSString *rest = [keyPath substringFromIndex:(delimeterRange.location + 1)];

    if ([self canSetValueForKey:first]) {
        return [[self valueForKey:first] canSetValueForKeyPath:rest];
    }

    return NO;
}

@end
