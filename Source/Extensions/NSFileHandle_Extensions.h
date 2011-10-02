//
//  NSFileHandle_Extensions.h
//  toxicsoftware.com
//
//  Created by Jonathan Wight on 9/14/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileHandle (Extensions)

+ (id)fileHandleWithTemporaryFile;

@property (readonly, nonatomic, retain) NSURL *URL;

@end
