//
//  CTypedData.m
//  toxicsoftware.com
//
//  Created by Jonathan Wight on 8/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

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