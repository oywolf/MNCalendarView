#import "MNCalendarView.h"

@interface MNEvent : NSObject
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) id userData;
@end

@interface MNDateEvent : MNEvent
@property (nonatomic, assign) BOOL allDayEvent;
@property (nonatomic, readonly, getter = isSingleAllDayEvent) BOOL singleAllDayEvent;
@property (nonatomic, readonly) NSDate *startDate;
@property (nonatomic, readonly) NSDate *endDate;
+ (instancetype) dateEventWithStartTime:(NSDate*)startTime endTime:(NSDate*)endTime andColor:(UIColor *)color userData:(id)userData;
@end

@interface MNTimeEvent : MNEvent
@property (nonatomic, readwrite) NSDate *date;
+ (instancetype) timeEventWithStartTime:(NSDate*)startTime endTime:(NSDate*)endTime andColor:(UIColor *)color userData:(id)userData;
@end

@class MNEventCalendarView;

@protocol MNEventCalendarViewDelegate <NSObject>
@optional
/// @param events Array of MNEvent.
- (void)eventCalendarView:(MNEventCalendarView *)eventCalendarView didSelectDate:(NSDate *)date withEvents:(NSArray *)events;
@end

@interface MNEventCalendarView : MNCalendarView
@property (nonatomic, weak) id<MNEventCalendarViewDelegate>eventDelegate;
- (void)addEvent:(MNEvent *)event;
/// @returns Array of MNDateEvent objects.
- (NSArray *)dateEventsForDate:(NSDate*)date;
/// @returns Array of MNTimeEvent objects.
- (NSArray *)timeEventsForDate:(NSDate *)date;
@end

