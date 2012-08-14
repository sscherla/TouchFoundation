//
//  NSSet+NSSet_Extensions.h
//  SetTest
//
//  Created by Jonathan Wight on 1/27/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (NSSet_Extensions)

- (NSSet *)setByRemovingObjectsInSet:(NSSet *)inSet;
+ (NSSet *)setWithIntersectionOfSets:(NSSet *)inSet, ...;

@end
