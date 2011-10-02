//
//  NSFileHandle_Extensions.m
//  toxicsoftware.com
//
//  Created by Jonathan Wight on 9/14/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "NSFileHandle_Extensions.h"

#include <fcntl.h>

@implementation NSFileHandle (Extensions)

+ (id)fileHandleWithTemporaryFile
    {
    NSFileHandle *theFileHandle = NULL;
    
    NSString *thePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"XXXXXXXXXXXXXXXX"];
    size_t theBufferLength = strlen([thePath UTF8String]) + 1;
    char thePathBuffer[theBufferLength];
    strncpy(thePathBuffer, [thePath UTF8String], theBufferLength);
    
    int theFileDescriptor = mkstemp(thePathBuffer);
    
    NSLog(@"mkstemp: %s", thePathBuffer); 
    
    if (theFileDescriptor >= 0)
        {
        theFileHandle = [[NSFileHandle alloc] initWithFileDescriptor:theFileDescriptor];
        }
    else
        {
        NSLog(@"Could not create temp file: %d", errno);
        }
    
    return(theFileHandle);
    }

- (NSURL *)URL
    {
    NSURL *theURL = NULL;
    char thePathBuffer[1024];
//    memset(thePathBuffer, 0, 1024);
            
    int theFileDescriptor = [self fileDescriptor];
    if (fcntl(theFileDescriptor, F_GETPATH, thePathBuffer) == 0)
        {
        NSLog(@">> %s\n", thePathBuffer);
        theURL = [NSURL fileURLWithPath:[NSString stringWithUTF8String:thePathBuffer]];
        }

    return(theURL);
    }

@end
