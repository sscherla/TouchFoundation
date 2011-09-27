//
//  CHumanDateFormatter.m
//  TouchCode
//
//  Created by Jonathan Wight on 9/12/08.
//  Copyright 2008 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "CHumanDateFormatter.h"

@implementation CHumanDateFormatter

@synthesize flags;

// TODO one way to speed this up is to pre-init all the subDateFormatter objects (as statics).

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
            theDeltaInUnits = theDelta / (365.254 / 12.0);
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
