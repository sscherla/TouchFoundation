//
//  CTypedData.h
//  toxicsoftware.com
//
//  Created by Jonathan Wight on 8/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTypedData : NSObject

@property (readonly, nonatomic, retain) NSString *type;
@property (readonly, nonatomic, retain) NSData *data;
@property (readonly, nonatomic, retain) NSDictionary *metadata;

- (id)initWithType:(NSString *)inType data:(NSData *)inData metadata:(NSDictionary *)inMetadata;
- (id)initWithType:(NSString *)inType data:(NSData *)inData;

@end

#pragma mark -

@interface CTypedData (CTypedData_Conversions)

- (id)initByTransformingObject:(id)inObject;

- (id)transformedObject;

@end