//
//  CTypedData+JSONExtensions.m
//  knotes
//
//  Created by Jonathan Wight on 10/10/11.
//  Copyright (c) 2011 knotes. All rights reserved.
//

#import "CTypedData+JSONExtensions.h"

@implementation CTypedData (JSONExtensions)

- (NSDictionary *)asDictionary
    {
    NSMutableDictionary *theDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        self.type, @"type",
        self.data, @"data",
        self.metadata, @"metadata",
        NULL];
    return(theDictionary);
    }

@end
