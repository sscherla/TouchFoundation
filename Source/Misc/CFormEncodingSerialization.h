//
//  CFormEncodingSerialization.h
//  //  TouchFoundation
//
//  Created by Jonathan Wight on 10/10/11.
//  Copyright (c) 2011 Jonathan Wight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFormEncodingSerialization : NSObject

+ (NSData *)dataWithDictionary:(NSDictionary *)inDictionay error:(NSError **)outError;
+ (NSData *)dataWithString:(NSString *)inString error:(NSError **)outError;

@end
