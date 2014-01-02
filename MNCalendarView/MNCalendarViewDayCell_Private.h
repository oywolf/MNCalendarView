#import "MNCalendarViewDayCell.h"

@interface MNCalendarViewDayCell()

@property(nonatomic,strong,readwrite) NSDate *date;
@property(nonatomic,strong,readwrite) NSDate *month;
@property(nonatomic,assign,readwrite) NSUInteger weekday;
@property(nonatomic,strong,readwrite) NSArray *dotColors;
@property(nonatomic,strong,readwrite) NSArray *allDayAnnotations;
@property(nonatomic,assign,readwrite) BOOL showsPsuedoDates;
@property(nonatomic,assign,readwrite) BOOL psuedoDate;
@property(nonatomic,assign,readwrite) BOOL drawRightSeparator;

@end
