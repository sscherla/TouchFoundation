//
//  NSObject_KVCExtensions.h
//
//  Created by Avi Itskovich on 8/19/11
//  Copyright 2011 Avi Itskovich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSObject_KVCExtensions)

- (BOOL)canSetValueForKey:(NSString *)key;
- (BOOL)canSetValueForKeyPath:(NSString *)keyPath;

@end
