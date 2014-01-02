//
//  NSDate+MNAdditions.h
//  MNCalendarView
//
//  Created by Min Kim on 7/26/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (MNAdditions)

- (instancetype)mn_firstDateOfMonth:(NSCalendar *)calendar;

- (instancetype)mn_lastDateOfMonth:(NSCalendar *)calendar;

- (instancetype)mn_beginningOfDay:(NSCalendar *)calendar;

- (instancetype)mn_dateWithDay:(NSUInteger)day calendar:(NSCalendar *)calendar;

@end

@interface NSDate (MNAdditional)
+ (NSDate *)mn_dateFromDate:(NSDate *)date hour:(NSInteger)hour minute:(NSInteger)minute;
+ (NSDate *)mn_dateFromDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;
+ (NSDate *)mn_dateFromDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year hour:(NSInteger)hour minute:(NSInteger)minute;
+ (NSDate *)mn_dateWithNoTime:(NSDate *)dateTime;
+ (NSDate *)mn_dateWithNoTime:(NSDate *)dateTime middleDay:(BOOL)middle;
- (NSUInteger)mn_numberOfDaysInMonth;
- (BOOL)mn_isEqualToDay:(NSDate *)day;
@end