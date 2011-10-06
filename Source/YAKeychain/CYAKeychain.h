//
//  CYAKeychain.h
//  TouchCode
//
//  Created by Jonathan Wight on 10/4/11.
//  Copyright (c) 2011 Jonathan Wight.. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kYAKeychain_ErrorDomain;

@interface CYAKeychain : NSObject

@property (readwrite, nonatomic, retain) NSString *accessGroup;

- (NSData *)dataForItemWithQuery:(NSDictionary *)inQueryDictionary error:(NSError **)outError;
- (BOOL)setData:(NSData *)inData forItemWithQuery:(NSDictionary *)inQueryDictionary error:(NSError **)outError;
- (BOOL)removeItemForQuery:(NSDictionary *)inQueryDictionary error:(NSError **)outError;

- (NSData *)dataForItemWithAccount:(NSString *)inAccount service:(NSString *)inService error:(NSError **)outError;
- (BOOL)setData:(NSData *)inData forItemWithAccount:(NSString *)inAccount service:(NSString *)inService error:(NSError **)outError;
- (BOOL)removeItemForAccount:(NSString *)inAccount service:(NSString *)inService error:(NSError **)outError;

- (NSData *)dataForItemWithURL:(NSURL *)inURL error:(NSError **)outError;
- (BOOL)setData:(NSData *)inData forItemWithURL:(NSURL *)inURL error:(NSError **)outError;
- (BOOL)removeItemForURL:(NSURL *)inURL error:(NSError **)outError;

@end

#pragma mark -

@interface CYAKeychain (CYAKeychain_ConvenienceExtensions)

- (NSString *)stringForItemWithAccount:(NSString *)inAccount service:(NSString *)inService error:(NSError **)outError;
- (BOOL)setString:(NSString *)inString forItemWithAccount:(NSString *)inAccount service:(NSString *)inService error:(NSError **)outError;

@end