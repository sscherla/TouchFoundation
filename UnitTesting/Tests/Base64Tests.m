//
//  Base64Tests.m
//  UnitTesting
//
//  Created by Jonathan Wight on 12/9/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "Base64Tests.h"

#import "NSData_Base64Extensions.h"

@implementation Base64Tests

- (void)testBase64LongWithCRLF
    {
    NSString *theSourceString = @"Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.";
    NSData *theSourceData = [theSourceString dataUsingEncoding:NSASCIIStringEncoding];
    NSString *theExpectedBase64String = @"TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlz\r\nIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2Yg\r\ndGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGlu\r\ndWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo\r\nZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=";

    NSString *theBase64String1 = [theSourceData asBase64EncodedString:Base64Flags_IncludeNewlines];
    STAssertEqualObjects(theBase64String1, theExpectedBase64String, @"Base64 encoding didn't match");
    }

- (void)testBase64LongWithoutCRLF
    {
    NSString *theSourceString = @"Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure.";
    NSData *theSourceData = [theSourceString dataUsingEncoding:NSASCIIStringEncoding];
    NSString *theExpectedBase64String = @"TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlz\r\nIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2Yg\r\ndGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGlu\r\ndWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo\r\nZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=";
    theExpectedBase64String = [theExpectedBase64String stringByReplacingOccurrencesOfString:@"\r\n" withString:@"" options:0 range:(NSRange){ .length = theExpectedBase64String.length }];

    NSString *theBase64String1 = [theSourceData asBase64EncodedString:0];
    STAssertEqualObjects(theBase64String1, theExpectedBase64String, @"Base64 encoding didn't match");
    }

- (void)testBase64Short1
    {
    NSString *theSourceString = @"X";
    NSData *theSourceData = [theSourceString dataUsingEncoding:NSASCIIStringEncoding];
    NSString *theExpectedBase64String = @"WA==";
    NSString *theBase64String1 = [theSourceData asBase64EncodedString:Base64Flags_IncludeNewlines];
    STAssertEqualObjects(theBase64String1, theExpectedBase64String, @"Base64 encoding didn't match");
    }

- (void)testBase64Short2
    {
    NSString *theSourceString = @"XY";
    NSData *theSourceData = [theSourceString dataUsingEncoding:NSASCIIStringEncoding];
    NSString *theExpectedBase64String = @"WFk=";
    NSString *theBase64String1 = [theSourceData asBase64EncodedString:Base64Flags_IncludeNewlines];
    STAssertEqualObjects(theBase64String1, theExpectedBase64String, @"Base64 encoding didn't match");
    }

- (void)testBase64Short3
    {
    NSString *theSourceString = @"XYZ";
    NSData *theSourceData = [theSourceString dataUsingEncoding:NSASCIIStringEncoding];
    NSString *theExpectedBase64String = @"WFla";
    NSString *theBase64String1 = [theSourceData asBase64EncodedString:Base64Flags_IncludeNewlines];
    STAssertEqualObjects(theBase64String1, theExpectedBase64String, @"Base64 encoding didn't match");
    }

- (void)testBase64Short4
    {
    NSString *theSourceString = @"XYZA";
    NSData *theSourceData = [theSourceString dataUsingEncoding:NSASCIIStringEncoding];
    NSString *theExpectedBase64String = @"WFlaQQ==";
    NSString *theBase64String1 = [theSourceData asBase64EncodedString:Base64Flags_IncludeNewlines];
    STAssertEqualObjects(theBase64String1, theExpectedBase64String, @"Base64 encoding didn't match");
    }

- (void)testBase64Data1
    {
    NSString *theSourceString = @"XYZA";
    NSData *theSourceData = [theSourceString dataUsingEncoding:NSASCIIStringEncoding];
    NSData *theExpectedBase64Data = [@"WFlaQQ==" dataUsingEncoding:NSASCIIStringEncoding];
    NSData *theBase64Data = [theSourceData asBase64EncodedData:Base64Flags_IncludeNewlines];
    STAssertEqualObjects(theBase64Data, theExpectedBase64Data, @"Base64 encoding didn't match");
    }

- (void)testBase64DataWithNullBytes
    {
    NSString *theSourceString = @"XYZA";
    NSData *theSourceData = [theSourceString dataUsingEncoding:NSASCIIStringEncoding];
    NSData *theExpectedBase64Data = [@"WFlaQQ==\0" dataUsingEncoding:NSASCIIStringEncoding];
    NSData *theBase64Data = [theSourceData asBase64EncodedData:Base64Flags_IncludeNewlines | Base64Flags_IncludeNullByte];
    STAssertEqualObjects(theBase64Data, theExpectedBase64Data, @"Base64 encoding didn't match");
    }

@end
