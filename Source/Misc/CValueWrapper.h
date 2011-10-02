//
//  CValueWrapper.h
//  toxicsoftware.com
//
//  Created by Jonathan Wight on 9/14/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CValueWrapper : NSObject <NSCoding>

@property (readonly, nonatomic, retain) NSValue *value;

- (id)initWithValue:(NSValue *)inValue;

@end
