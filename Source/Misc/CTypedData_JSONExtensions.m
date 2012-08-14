//
//  CTypedData_JSONExtensions.m
//  //  TouchFoundation
//
//  Created by Jonathan Wight on 10/10/11.
//  Copyright (c) 2011 Jonathan Wight. All rights reserved.
//

#import "CTypedData_JSONExtensions.h"

@implementation CTypedData (CTypedData_JSONExtensions)

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
