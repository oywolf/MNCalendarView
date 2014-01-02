#import "MNEventCalendarView.h"
#import "NSDate+MNAdditions.h"
#import "MNAnnotation.h"

const NSInteger kUninitializedRow = -1;
const NSInteger kMaxEventsPerDay = 3;

@implementation MNEvent
- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@: %@ - %@ (%@)", self.class, self.startTime, self.endTime, self.userData];
}
@end

@interface MNDateEvent ()
@property (nonatomic, readwrite) NSInteger row;
@end
@implementation MNDateEvent
- (NSDate *)startDate {
    return [NSDate mn_dateWithNoTime:self.startTime];
}
- (NSDate *)endDate {
    return [NSDate mn_dateWithNoTime:self.endTime];
}
- (void)resetRow {
    self.row = kUninitializedRow;
}
+ (instancetype) dateEventWithStartTime:(NSDate*)startTime endTime:(NSDate*)endTime andColor:(UIColor *)color userData:(id)userData {
    MNDateEvent *event = [[self class] new];
    event.startTime = startTime;
    event.endTime = endTime;
    event.color = color;
    event.userData = userData;
    return event;
}
@end

@implementation MNTimeEvent
- (NSDate *)date {
    return [NSDate mn_dateWithNoTime:self.startTime];
}
+ (instancetype)timeEventWithStartTime:(NSDate *)startTime endTime:(NSDate *)endTime andColor:(UIColor *)color userData:(id)userData {
    NSAssert([startTime mn_isEqualToDay:endTime], @"Must have equal dates.");
    MNTimeEvent *event = [[[self class] alloc] init];
    event.startTime = startTime;
    event.endTime = endTime;
    event.color = color;
    event.userData = userData;
    return event;
}
@end

@interface MNCalendarView ()
- (void)commonInit; // make this method visible
@end

@interface MNEventCalendarView ()<MNCalendarViewDelegate>
/// Sorted array of MNTimeEvent. Events are sorted by startTime (earliest first), then by endTime (latestFirst).
@property (nonatomic, strong) NSMutableArray *timeEvents;
/// Sorted array of MNDateEvent. Events are sorted by startTime (earliest first), then by endTime (latestFirst).
@property (nonatomic, strong) NSMutableArray *dateEvents;
@end

@implementation MNEventCalendarView

@synthesize delegate = _delegate;

- (void)setDelegate:(id<MNCalendarViewDelegate>)delegate {
    NSAssert(NO, @"Must not set the delegate. Instead, use eventDelegate.");
}

- (void)commonInit {
    [super commonInit];
    
    self.timeEvents = [NSMutableArray array];
    self.dateEvents = [NSMutableArray array];
    _delegate = self;
}

- (void)addEvent:(MNEvent *)event {
    NSMutableArray *arrayToSort;
    if ([event isKindOfClass:[MNTimeEvent class]]) {
        [self.timeEvents addObject:event];
        arrayToSort = self.timeEvents;
    } else {
        NSAssert([event isKindOfClass:[MNDateEvent class]], @"Expected date event.");
        [self.dateEvents addObject:event];
        arrayToSort = self.dateEvents;
    }
    
    // TODO: don't have to sort every single time, we only need to resort those that intersect with this event
    [arrayToSort sortUsingComparator:^NSComparisonResult(MNTimeEvent *obj1, MNTimeEvent *obj2) {
        NSComparisonResult timeComparison = [obj1.startTime compare:obj2.startTime];
        if (timeComparison == NSOrderedSame) {
            timeComparison = -[obj1.endTime compare:obj2.endTime];
            // TODO: if the timeComparison is the same here, do we want to sort by some other criteria as well?
        }
        return timeComparison;
    }];
    
    if ([event isKindOfClass:[MNDateEvent class]]) {
        // we had to resort the array, so now get new rows for each object
        [self.dateEvents makeObjectsPerformSelector:@selector(resetRow)];
        for (MNDateEvent *event in self.dateEvents) {
            if (event.row != kUninitializedRow)
                continue;
            
            /// Array of MNDateEvent objects
            NSArray *sharedEvents = [self dateEventsForDate:event.startDate];
            /// Array of NSNumbers, sorted by smallest.
            NSMutableArray *availableSlots = [@[] mutableCopy];
            for (int i = 0; i <= sharedEvents.count; i++) {
                [availableSlots addObject:@(i)];
            }
            for (MNDateEvent *sharedEvent in sharedEvents) {
                if (sharedEvent.row != kUninitializedRow) {
                    [availableSlots removeObject:@(sharedEvent.row)];
                }
            }
            
            event.row = [availableSlots[0] integerValue];
        }
    }
}

- (NSArray *)dateEventsForDate:(NSDate*)date {
    NSMutableArray *events = [NSMutableArray array];
    for (MNDateEvent *event in self.dateEvents) {
        if ([event.startDate compare:[NSDate mn_dateWithNoTime:date]] != NSOrderedDescending  && [event.endDate compare:[NSDate mn_dateWithNoTime:date]] != NSOrderedAscending) {
            [events addObject:event];
        }
    }
    
    return events;
}

- (NSArray *)timeEventsForDate:(NSDate *)date {
    NSMutableArray *events = [NSMutableArray array];
    for (MNTimeEvent *event in self.timeEvents) {
        if ([event.date mn_isEqualToDay:date]) {
            [events addObject:event];
        }
    }
    return events;
}

#pragma mark - MNCalendarViewDelegate

- (NSArray *)calendarView:(MNCalendarView *)calendarView dotColorsForDate:(NSDate *)date {
    NSMutableArray *dots = [NSMutableArray array];
    for (MNTimeEvent *event in [self timeEventsForDate:date]) {
        NSAssert([event isKindOfClass:[MNTimeEvent class]], @"Expecting time objects.");
        [dots addObject:event.color];
    }
    return dots;
}

- (NSArray *)calendarView:(MNCalendarView *)calendarView allDayAnnotationsForDate:(NSDate *)date {
    NSMutableArray *events = [NSMutableArray array];
    NSArray *dateEvents = [self dateEventsForDate:date];
    for (int i = 0; i < kMaxEventsPerDay; i++) {
        MNAnnotation *annotation = [MNAnnotation annotationOfType:MNAnnotationTypeNone andColor:nil];
        for (MNDateEvent *event in dateEvents) {
            NSAssert([event isKindOfClass:[MNDateEvent class]], @"Expecting date objects.");
            if (event.row != i) {
                continue;
            }
            MNAnnotationType annotationType;
            if ([event.startDate mn_isEqualToDay:date] && [event.endDate mn_isEqualToDay:date]) {
                annotationType = MNAnnotationTypeAllDay;
            } else if ([event.startDate mn_isEqualToDay:date]) {
                annotationType = MNAnnotationTypeMultiDayStart;
            } else if ([event.endDate mn_isEqualToDay:date]) {
                annotationType = MNAnnotationTypeMultiDayEnd;
            } else {
                annotationType = MNAnnotationTypeMultiDayMiddle;
            }
            annotation = [MNAnnotation annotationOfType:annotationType andColor:event.color];
        }
        [events addObject:annotation];
    }
    
    return events;
}

- (void)calendarView:(MNCalendarView *)calendarView didSelectDate:(NSDate *)date {
    if ([self.eventDelegate respondsToSelector:@selector(eventCalendarView:didSelectDate:withEvents:)]) {
        NSArray *events = [[self dateEventsForDate:date] arrayByAddingObjectsFromArray:[self timeEventsForDate:date]];
        [self.eventDelegate eventCalendarView:self didSelectDate:date withEvents:events];
    }
}

@end
