//
//  CFormEncodingSerialization.m
//  //  TouchFoundation
//
//  Created by Jonathan Wight on 10/10/11.
//  Copyright (c) 2011 Jonathan Wight. All rights reserved.
//

#import "CFormEncodingSerialization.h"

@implementation CFormEncodingSerialization

// http://www.w3.org/TR/html4/interact/forms.html#h-17.13.4.1

+ (NSData *)dataWithDictionary:(NSDictionary *)inDictionary error:(NSError **)outError
    {
    NSMutableData *theData = [NSMutableData data];
    
    __block BOOL theAtStartFlag = YES;
    [inDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if (theAtStartFlag == NO)
            {
            [theData appendBytes:"&" length:1];
            }
        else
            {
            theAtStartFlag = NO;
            }
        
        NSData *theKeyData = [self dataWithString:key error:NULL];
        [theData appendData:theKeyData];
        [theData appendBytes:"=" length:1];
        NSData *theValueData = [self dataWithString:obj error:NULL];
        [theData appendData:theValueData];
        }];
    
    return(theData);
    }

+ (NSData *)dataWithString:(NSString *)inString error:(NSError **)outError
    {
    NSString *theString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)inString, CFSTR(" \n\r"), CFSTR("!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"), kCFStringEncodingUTF8);
    theString = [theString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSData *theData = [theString dataUsingEncoding:NSUTF8StringEncoding];    
    return(theData);   
    }

@end
