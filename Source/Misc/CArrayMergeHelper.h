//
//  CArrayMergeHelper.h
//  Jonathan Wight
//
//  Created by Jonathan Wight on 8/5/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CArrayMergeHelper : NSObject

@property (readwrite, nonatomic, strong) NSArray *leftArray;
@property (readwrite, nonatomic, strong) NSString *leftKey;

@property (readwrite, nonatomic, strong) NSArray *rightArray;
@property (readwrite, nonatomic, strong) NSString *rightKey;

@property (readwrite, nonatomic, copy) id (^insertHandler)(id inRightObject);
@property (readwrite, nonatomic, copy) id (^updateHandler)(id inLeftObject, id inRightObject);

- (NSArray *)merge:(NSError **)outError;

@end
