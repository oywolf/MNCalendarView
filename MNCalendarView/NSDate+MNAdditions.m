//
//  NSDate+MNAdditions.m
//  MNCalendarView
//
//  Created by Min Kim on 7/26/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "NSDate+MNAdditions.h"

@implementation NSDate (MNAdditions)

- (instancetype)mn_firstDateOfMonth:(NSCalendar *)calendar {
  if (nil == calendar) {
    calendar = [NSCalendar currentCalendar];
  }
  
  NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
  
  [components setDay:1];
  
  return [calendar dateFromComponents:components];
}

- (instancetype)mn_lastDateOfMonth:(NSCalendar *)calendar {
  if (nil == calendar) {
    calendar = [NSCalendar currentCalendar];
  }
  
  NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
  [components setDay:0];
  [components setMonth:components.month + 1];
  
  return [calendar dateFromComponents:components];
}

- (instancetype)mn_beginningOfDay:(NSCalendar *)calendar {
  if (nil == calendar) {
    calendar = [NSCalendar currentCalendar];
  }
  NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
  [components setHour:0];
  
  return [calendar dateFromComponents:components];
}

- (instancetype)mn_dateWithDay:(NSUInteger)day calendar:(NSCalendar *)calendar {
  if (nil == calendar) {
    calendar = [NSCalendar currentCalendar];
  }
  NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
  
  [components setDay:day];
  
  return [calendar dateFromComponents:components];
}

@end

@implementation NSDate (MNAdditional)

+ (NSDate *)mn_dateFromDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year {
    return [self mn_dateFromDay:day month:month year:year hour:0 minute:0];
}
+ (NSDate *)mn_dateFromDate:(NSDate *)date hour:(NSInteger)hour minute:(NSInteger)minute {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date]; // TODO: what about era?
    [components setHour:hour];
    [components setMinute:minute];
    return [components date];
}
+ (NSDate *)mn_dateFromDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year hour:(NSInteger)hour minute:(NSInteger)minute {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    [components setDay:day];
    
    if (month <= 0) {
        [components setMonth:12-month];
        [components setYear:year-1];
    } else if (month >= 13) {
        [components setMonth:month-12];
        [components setYear:year+1];
    } else {
        [components setMonth:month];
        [components setYear:year];
    }

    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:0];
    
    return [calendar dateFromComponents:components];
}
+ (NSDate *)mn_dateWithNoTime:(NSDate *)dateTime {
  return [self mn_dateWithNoTime:dateTime middleDay:NO];
}
+ (NSDate *)mn_dateWithNoTime:(NSDate *)dateTime middleDay:(BOOL)middle {
    if( dateTime == nil ) {
        dateTime = [NSDate date];
    }

    NSCalendar       *calendar   = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                             fromDate:dateTime];

    NSDate *dateOnly = [calendar dateFromComponents:components];

    if (middle)
        dateOnly = [dateOnly dateByAddingTimeInterval:(60.0 * 60.0 * 12.0)];           // Push to Middle of day.

    return dateOnly;
}

- (NSUInteger)mn_numberOfDaysInMonth {
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSDayCalendarUnit
                           inUnit:NSMonthCalendarUnit
                          forDate:self];

    return days.length;
}

- (BOOL)mn_isEqualToDay:(NSDate *)day {
  return [[NSDate mn_dateWithNoTime:self] isEqualToDate:[NSDate mn_dateWithNoTime:day]];
}


@end
