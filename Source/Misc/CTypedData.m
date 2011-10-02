//
//  CTypedData.m
//  TouchCode
//
//  Created by Jonathan Wight on 8/10/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
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
//  THIS SOFTWARE IS PROVIDED BY 2011 TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 2011 TOXICSOFTWARE.COM OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of 2011 toxicsoftware.com.

#import "CTypedData.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "UIImage_Extensions.h"

@implementation CTypedData

@synthesize type;
@synthesize data;
@synthesize metadata;

- (id)initWithType:(NSString *)inType data:(NSData *)inData metadata:(NSDictionary *)inMetadata
    {
    NSParameterAssert(inType.length > 0);
    NSParameterAssert(inData);

    if ((self = [super init]) != NULL)
        {
        type = inType;
        data = inData;
        metadata = inMetadata;
        }
    return self;
    }

- (id)initWithType:(NSString *)inType data:(NSData *)inData;
    {
    if ((self = [self initWithType:inType data:inData metadata:NULL]) != NULL)
        {
        }
    return(self);
    }

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (type: %@, data: %d bytes, metadata: %@)", [super description], self.type, self.data.length, self.metadata]);
    }

@end

#pragma mark -

@implementation CTypedData (CTypedData_Conversions)

- (id)initByTransformingObject:(id)inObject
    {
    NSParameterAssert(inObject != NULL);

    NSString *theType = NULL;
    NSData *theData = NULL;
    NSDictionary *theMetadata = NULL;

    if ([inObject isKindOfClass:[UIImage class]])
        {
        UIImage *theImage = (UIImage *)inObject;

        theType = (__bridge NSString *)kUTTypePNG;
        theData = UIImagePNGRepresentation(theImage);
        theMetadata = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:theImage.scale], @"scale",
            [NSNumber numberWithInt:theImage.imageOrientation], @"orientation",
            NULL];
        }
    else if ([inObject isKindOfClass:[NSData class]])
        {
        theType = (__bridge NSString *)kUTTypeData;
        theData = inObject;
        }
    else if ([inObject isKindOfClass:[NSString class]])
        {
        theType = (__bridge NSString *)kUTTypeText;
        theData = [inObject dataUsingEncoding:NSUTF8StringEncoding];
        }
    else if ([inObject isKindOfClass:[NSURL class]])
        {
        theType = (__bridge NSString *)kUTTypeURL;
        theData = [[inObject absoluteString] dataUsingEncoding:NSUTF8StringEncoding];
        }
    else if ([inObject conformsToProtocol:@protocol(NSCoding)])
        {
        #warning Use real UTI type
        theType = @"com.toxicsoftware.NSKeyedArchiver";
        theData = [NSKeyedArchiver archivedDataWithRootObject:inObject];
        }
    else
        {
        self = NULL;
        return(NULL);
        }

    if ((self = [self initWithType:theType data:theData metadata:theMetadata]) != NULL)
        {
        }
    return self;
    }

- (id)transformedObject
    {
    id theObject = NULL;
    if (UTTypeConformsTo((__bridge CFStringRef)self.type, kUTTypeImage))
        {
        CGFloat theScale = [self.metadata objectForKey:@"scale"] ? [[self.metadata objectForKey:@"scale"] floatValue] : 1.0;
        UIImageOrientation theOrientation = [self.metadata objectForKey:@"orientation"] ? [[self.metadata objectForKey:@"orientation"] intValue] : UIImageOrientationUp;
        theObject = [UIImage imageWithData:self.data scale:theScale orientation:theOrientation];
        }
    else if (UTTypeConformsTo((__bridge CFStringRef)self.type, kUTTypeData))
        {
        theObject = self.data;
        }
    else if (UTTypeConformsTo((__bridge CFStringRef)self.type, kUTTypeText))
        {
        theObject = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        }
    else if (UTTypeConformsTo((__bridge CFStringRef)self.type, kUTTypeURL))
        {
        NSString *theString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        theObject = [NSURL URLWithString:theString];
        }
    else if ([self.type isEqualToString:@"com.toxicsoftware.NSKeyedArchiver"])
        {
        #warning Should use a real UTI type & UTTypeConformsTo
        theObject = [NSKeyedUnarchiver unarchiveObjectWithData:self.data];
        }
    return(theObject);
    }



@end
