//
//  CHumanDateFormatter.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/12/08.
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
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

#import "CHumanDateFormatter.h"

@implementation CHumanDateFormatter

@synthesize flags;

+ (id)humanDateFormatter:(NSUInteger)inFlags;
    {
    CHumanDateFormatter *theFormatter = [[self alloc] init];
    theFormatter.flags = inFlags;
    return(theFormatter);
    }

+ (NSString *)formatDate:(NSDate *)inDate flags:(NSUInteger)inFlags
    {
    CHumanDateFormatter *theDateFormatter = [self humanDateFormatter:inFlags];
    return([theDateFormatter stringFromDate:inDate]);
    }

- (NSString *)stringFromDate:(NSDate *)inDate
    {
    if (inDate == NULL)
        {
        return(NULL);
        }
        
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    
    NSMutableArray *theComponents = [NSMutableArray array];
    
    NSInteger theDayOfEra = [theCalendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:inDate];

    NSDate *theNow = [NSDate date];
    NSInteger theNowDayOfEra = [theCalendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:theNow];

    NSInteger theDelta = theNowDayOfEra - theDayOfEra;

    NSCalendarUnit theUnit = NSDayCalendarUnit;
    NSInteger theDeltaInUnits = 0;
    
    // #############################################################################

    if (theDelta == 0)
        {
        [theComponents addObject:@"Today"];
        }
    else if (theDelta == -1)
        {
        [theComponents addObject:@"Tomorrow"];
        }
    else if (theDelta == 1)
        {
        [theComponents addObject:@"Yesterday"];
        }
    else 
        {
        if (theDelta >= 2 && theDelta < 7)
            {
            theUnit = NSDayCalendarUnit;
            theDeltaInUnits = theDelta;
            }
        else if (theDelta >= 7 && theDelta < 30)
            {
            theUnit = NSWeekCalendarUnit;
            theDeltaInUnits = theDelta / 7;
            }
        else if (theDelta >= 30 && theDelta < 360)
            {
            theUnit = NSMonthCalendarUnit;
            theDeltaInUnits = (NSInteger)((NSTimeInterval)theDelta / (365.254 / 12.0));
            }
        else
            {
            NSDateFormatter *theSubDateFormatter = [[NSDateFormatter alloc] init];
            [theSubDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
            [theSubDateFormatter setDateStyle:NSDateFormatterShortStyle];
            [theSubDateFormatter setTimeStyle:NSDateFormatterNoStyle];

            [theComponents addObject:[theSubDateFormatter stringFromDate:inDate]];
            }
        }

    if (theDeltaInUnits)
        {
        NSString *theUnitString = NULL;
        if (theUnit == NSDayCalendarUnit)
            {
            if (self.flags & HumanDateFormatterFlags_Mini)
                {
                theUnitString = @"d";
                }
            else
                {
                theUnitString = theDeltaInUnits == 1 ? @"day" : @"days";
                }
            }
        else if (theUnit == NSWeekCalendarUnit)
            {
            if (self.flags & HumanDateFormatterFlags_Mini)
                {
                theUnitString = @"w";
                }
            else
                {
                theUnitString = theDeltaInUnits == 1 ? @"week" : @"weeks";
                }
            }
        else if (theUnit == NSMonthCalendarUnit)
            {
            if (self.flags & HumanDateFormatterFlags_Mini)
                {
                theUnitString = @"m";
                }
            else
                {
                theUnitString = theDeltaInUnits == 1 ? @"month" : @"months";
                }
            }
        
        if (self.flags & HumanDateFormatterFlags_Mini)
            {
            [theComponents addObject:[NSString stringWithFormat:@"%d%@", theDeltaInUnits, theUnitString]];
            }
        else
            {
            [theComponents addObject:[NSString stringWithFormat:@"%d %@%@", labs(theDeltaInUnits), theUnitString, theDeltaInUnits > 0 ? @" ago" : @""]];
            }
        }

    // #############################################################################

    if (self.flags & HumanDateFormatterFlags_IncludeTime)
        {
        NSDateFormatter *theSubDateFormatter = [[NSDateFormatter alloc] init];
        [theSubDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [theSubDateFormatter setDateStyle:NSDateFormatterNoStyle];
        [theSubDateFormatter setTimeStyle:NSDateFormatterShortStyle];

        [theComponents addObject:[theSubDateFormatter stringFromDate:inDate]];
        }

    return([theComponents componentsJoinedByString:self.flags & HumanDateFormatterFlags_MultiLine ? @"\n" : @", "]);
    
    }

@end
