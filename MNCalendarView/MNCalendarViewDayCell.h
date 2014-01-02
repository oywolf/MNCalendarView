//
//  MNCalendarViewDayCell.h
//  MNCalendarView
//
//  Created by Min Kim on 7/28/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarViewCell.h"

extern NSString *const MNCalendarViewDayCellIdentifier;

@interface MNCalendarViewDayCell : MNCalendarViewCell

@property(nonatomic,strong,readonly) NSDate *date;
@property(nonatomic,strong,readonly) NSDate *month;
/// Array of UIColor
@property(nonatomic,strong,readonly) NSArray *dotColors;
/// Array of MNAnnotation
@property(nonatomic,strong,readonly) NSArray *allDayAnnotations;
/// This a cell which represents a date from the previous/next month.
@property(nonatomic,readonly) BOOL psuedoDate;

@end
