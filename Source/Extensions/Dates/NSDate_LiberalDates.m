//
//	NSDateFormatter_LiberalDates.m
//	TouchCode
//
//	Created by Devin Chalmers on 3/30/11.
//	Copyright 2011 Devin Chalmers. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	   1. Redistributions of source code must retain the above copyright notice, this list of
//		  conditions and the following disclaimer.
//
//	   2. Redistributions in binary form must reproduce the above copyright notice, this list
//		  of conditions and the following disclaimer in the documentation and/or other materials
//		  provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY DEVIN CHALMERS ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL DEVIN CHALMERS OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of Devin Chalmers.

#import "NSDate_LiberalDates.h"


@implementation NSDate (LiberalDates)

+ (NSDate *)dateWithInternetString:(NSString *)dateString;
{
    return [self dateWithInternetString:dateString useFormatter:nil];
}

+ (NSDate *)dateWithInternetString:(NSString *)dateString useFormatter:(NSDateFormatter **)outFormatter;
{
    if (outFormatter && *outFormatter) return [*outFormatter dateFromString:dateString];
    
	NSDate *date = nil;
    
	for (NSDateFormatter *formatter in [NSDateFormatter allISO8601DateFormatters]) {
		date = [formatter dateFromString:dateString];
		if (date)
        {
            if (outFormatter) *outFormatter = formatter;
            return date;
        }
	}

	for (NSDateFormatter *formatter in [NSDateFormatter allRFC2822DateFormatters]) {
		date = [formatter dateFromString:dateString];
		if (date)
        {
            if (outFormatter) *outFormatter = formatter;
            return date;
        }
	}

	for (NSDateFormatter *formatter in [NSDateFormatter allInternetDateFormatters]) {
		date = [formatter dateFromString:dateString];
		if (date)
        {
            if (outFormatter) *outFormatter = formatter;
            return date;
        }
	}

	return date;
}

@end
