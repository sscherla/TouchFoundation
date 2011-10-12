//
//  CYAKeychain.h
//  TouchCode
//
//  Created by Jonathan Wight on 10/4/11.
//  Copyright 2011 Jonathan Wight. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	   1. Redistributions of source code must retain the above copyright notice, this list of
//	      conditions and the following disclaimer.
//
//	   2. Redistributions in binary form must reproduce the above copyright notice, this list
//	      of conditions and the following disclaimer in the documentation and/or other materials
//	      provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY 2011 TOXICSOFTWARE.COM ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 2011 TOXICSOFTWARE.COM OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of 2011 toxicsoftware.com.

#import <Foundation/Foundation.h>

extern NSString *const kYAKeychain_ErrorDomain;

@interface CYAKeychain : NSObject

@property (readwrite, nonatomic, strong) NSString *accessGroup;

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