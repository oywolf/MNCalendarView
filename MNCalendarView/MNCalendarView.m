//
//  MNCalendarView.m
//  MNCalendarView
//
//  Created by Min Kim on 7/23/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarView.h"
#import "MNCalendarViewLayout.h"
#import "MNCalendarViewDayCell.h"
#import "MNCalendarViewWeekdayCell.h"
#import "MNCalendarHeaderView.h"
#import "MNFastDateEnumeration.h"
#import "NSDate+MNAdditions.h"
#import "MNCalendarViewDayCell_Private.h"

@interface MNCalendarView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic,strong,readwrite) UICollectionView *collectionView;
@property(nonatomic,strong,readwrite) UICollectionViewFlowLayout *layout;

@property(nonatomic,strong,readwrite) NSArray *monthDates;
@property(nonatomic,strong,readwrite) NSArray *weekdaySymbols;
@property(nonatomic,assign,readwrite) NSUInteger daysInWeek;

@property(nonatomic,strong,readwrite) NSDateFormatter *monthFormatter;

- (NSDate *)firstVisibleDateOfMonth:(NSDate *)date;
- (NSDate *)lastVisibleDateOfMonth:(NSDate *)date;

- (BOOL)dateEnabled:(NSDate *)date;
- (BOOL)canSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)applyConstraints;

@end

@implementation MNCalendarView

- (void)commonInit {
    self.calendar   = NSCalendar.currentCalendar;
    self.fromDate   = [NSDate.date mn_beginningOfDay:self.calendar];
#warning TODO: restore this line
//    self.toDate     = [self.fromDate dateByAddingTimeInterval:MN_YEAR * 4];
    self.toDate     = [self.fromDate dateByAddingTimeInterval:MN_YEAR];
    self.daysInWeek = 7;
    
    self.headerViewClass  = MNCalendarHeaderView.class;
    self.weekdayCellClass = MNCalendarViewWeekdayCell.class;
    self.dayCellClass     = MNCalendarViewDayCell.class;
    
    _separatorColor = [UIColor colorWithRed:.85f green:.85f blue:.85f alpha:1.f];
    
    [self addSubview:self.collectionView];
    [self applyConstraints];
    [self reloadData];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if ( self ) {
        [self commonInit];
    }
    
    return self;
}

- (UICollectionView *)collectionView {
    if (nil == _collectionView) {
        MNCalendarViewLayout *layout = [[MNCalendarViewLayout alloc] initWithHeaderHeight:54.f];
        
        _collectionView =
        [[UICollectionView alloc] initWithFrame:CGRectZero
                           collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor colorWithRed:.96f green:.96f blue:.96f alpha:1.f];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [self registerUICollectionViewClasses];
    }
    return _collectionView;
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
}

- (void)setCalendar:(NSCalendar *)calendar {
    _calendar = calendar;
    
    self.monthFormatter = [[NSDateFormatter alloc] init];
    self.monthFormatter.calendar = calendar;
    [self.monthFormatter setDateFormat:@"MMMM yyyy"];
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    [self.collectionView selectItemAtIndexPath:[self indexPathForConcreteDate:selectedDate] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (NSDate *)selectedDate {
    NSArray *selectedPaths = self.collectionView.indexPathsForSelectedItems;
    NSDate *date = nil;
    if (selectedPaths.count > 0) {
        date = [self dateForIndexPath:selectedPaths[0] andMonthDate:nil];
    }
    return date;
}

- (void)reloadData {
    NSMutableArray *monthDates = @[].mutableCopy;
    MNFastDateEnumeration *enumeration =
    [[MNFastDateEnumeration alloc] initWithFromDate:[self.fromDate mn_firstDateOfMonth:self.calendar]
                                             toDate:[self.toDate mn_firstDateOfMonth:self.calendar]
                                           calendar:self.calendar
                                               unit:NSMonthCalendarUnit];
    for (NSDate *date in enumeration) {
        [monthDates addObject:date];
    }
    self.monthDates = monthDates;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = self.calendar;
    
    self.weekdaySymbols = formatter.shortWeekdaySymbols;
    
    [self.collectionView reloadData];
}

- (void)registerUICollectionViewClasses {
    [_collectionView registerClass:self.dayCellClass
        forCellWithReuseIdentifier:MNCalendarViewDayCellIdentifier];
    
    [_collectionView registerClass:self.weekdayCellClass
        forCellWithReuseIdentifier:MNCalendarViewWeekdayCellIdentifier];
    
    [_collectionView registerClass:self.headerViewClass
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:MNCalendarHeaderViewIdentifier];
}

- (NSDate *)firstVisibleDateOfMonth:(NSDate *)date {
    date = [date mn_firstDateOfMonth:self.calendar];
    
    NSDateComponents *components =
    [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                     fromDate:date];
    
    return
    [[date mn_dateWithDay:-((components.weekday - 1) % self.daysInWeek) calendar:self.calendar] dateByAddingTimeInterval:MN_DAY];
}

- (NSDate *)lastVisibleDateOfMonth:(NSDate *)date {
    date = [date mn_lastDateOfMonth:self.calendar];
    
    NSDateComponents *components =
    [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                     fromDate:date];
    
    return
    [date mn_dateWithDay:components.day + (self.daysInWeek - 1) - ((components.weekday - 1) % self.daysInWeek)
                calendar:self.calendar];
}

- (void)applyConstraints {
    NSDictionary *views = @{@"collectionView" : self.collectionView};
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|"
                                             options:0
                                             metrics:nil
                                               views:views]
     ];
}

- (BOOL)canSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MNCalendarViewCell *cell = (MNCalendarViewCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.enabled;
}

/// @return The index path for a concrete date.
- (NSIndexPath *)indexPathForConcreteDate:(NSDate *)date {
    if (!date) {
        return nil;
    }
    NSDateComponents *dateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    NSDateComponents *fromDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:self.fromDate];
    // {5,13} to {7,13} = 2
    // {5,13} to {5,14} = 12
    // {5,13} to {2,14} = 9
    NSInteger indexPathSection = (dateComponents.year - fromDateComponents.year) * 12 + (dateComponents.month - fromDateComponents.month);
    
    if (indexPathSection < 0 || self.monthDates.count <= indexPathSection) {
        return nil;
    }
    
    NSDate *monthDate = self.monthDates[indexPathSection];
    NSDate *firstDateInMonth = [self firstVisibleDateOfMonth:monthDate];
    
    NSDateComponents *dayInVisibleMonthComponents = [self.calendar components:NSDayCalendarUnit fromDate:firstDateInMonth toDate:date options:0];
    
    NSInteger indexPathItem = dayInVisibleMonthComponents.day + self.daysInWeek;
    return [NSIndexPath indexPathForItem:indexPathItem inSection:indexPathSection];
}

/// This will return the date for either a concrete or psuedo indexPath.
- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath andMonthDate:(NSDate **)monthDateOut {
    if (indexPath.item < self.daysInWeek) {
        if (monthDateOut) {
            *monthDateOut = nil;
        }
        return nil;
    }
    NSDate *monthDate = self.monthDates[indexPath.section];
    NSDate *firstDateInMonth = [self firstVisibleDateOfMonth:monthDate];
    
    NSUInteger day = indexPath.item - self.daysInWeek;
    
    NSDateComponents *components =
    [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                     fromDate:firstDateInMonth];
    components.day += day;
    
    NSDate *date = [self.calendar dateFromComponents:components];
    if (monthDateOut) {
        *monthDateOut = monthDate;
    }
    return date;
}

- (NSIndexPath *)concreteIndexPathFromIndexPath:(NSIndexPath *)indexPath {
    NSDate *dateAtIndexPath = [self dateForIndexPath:indexPath andMonthDate:nil];
    return [self indexPathForConcreteDate:dateAtIndexPath];
}

- (BOOL)isPsuedoDateAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *concreteIndexPath = [self concreteIndexPathFromIndexPath:indexPath];
    return concreteIndexPath && ([indexPath compare:concreteIndexPath] != NSOrderedSame);
}

#pragma mark - Delegate Helpers

- (NSArray *)dotColorsForDate:(NSDate *)date {
    if ([self.delegate respondsToSelector:@selector(calendarView:dotColorsForDate:)]) {
        return [self.delegate calendarView:self dotColorsForDate:date];
    }
    return nil;
}

- (NSArray *)allDayAnnotationsForDate:(NSDate *)date {
    if ([self.delegate respondsToSelector:@selector(calendarView:allDayAnnotationsForDate:)]) {
        return [self.delegate calendarView:self allDayAnnotationsForDate:date];
    }
    return nil;
}

- (BOOL)dateEnabled:(NSDate *)date {
    if ([self.delegate respondsToSelector:@selector(calendarView:dateEnabled:)]) {
        return [self.delegate calendarView:self dateEnabled:date];
    }
    return YES;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.monthDates.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    MNCalendarHeaderView *headerView =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:MNCalendarHeaderViewIdentifier
                                              forIndexPath:indexPath];
    
    headerView.backgroundColor = self.collectionView.backgroundColor;
    headerView.titleLabel.text = [self.monthFormatter stringFromDate:self.monthDates[indexPath.section]];
    
    return headerView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDate *monthDate = self.monthDates[section];
    
    NSDateComponents *components =
    [self.calendar components:NSDayCalendarUnit
                     fromDate:[self firstVisibleDateOfMonth:monthDate]
                       toDate:[self lastVisibleDateOfMonth:monthDate]
                      options:0];
    
    return self.daysInWeek + components.day + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL drawBottomBorder = YES;
    NSDate *monthDate = self.monthDates[indexPath.section];
    NSDate *firstDateInMonth = [self firstVisibleDateOfMonth:monthDate];
    if (!self.showsPsuedoDates) {
        NSDateComponents *dateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                                                            fromDate:firstDateInMonth];
        dateComponents.day += indexPath.item;
        NSDateComponents *dateComponentsNextWeek = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                                                                    fromDate:[self.calendar dateFromComponents:dateComponents]];
        drawBottomBorder = dateComponentsNextWeek.day <= 7; //&& dateComponentsNextWeek.month == dateComponents.month;
    }
    
    if (indexPath.item < self.daysInWeek) {
        MNCalendarViewWeekdayCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:MNCalendarViewWeekdayCellIdentifier
                                                  forIndexPath:indexPath];
        
        cell.backgroundColor = self.collectionView.backgroundColor;
        cell.titleLabel.text = self.weekdaySymbols[indexPath.item];
        cell.separatorColor = self.separatorColor;
        cell.drawBottomSeparator = drawBottomBorder;
        return cell;
    }
    
    MNCalendarViewDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MNCalendarViewDayCellIdentifier
                                                                            forIndexPath:indexPath];
    cell.separatorColor = self.separatorColor;
    NSDateComponents *dateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                                                        fromDate:firstDateInMonth];
    NSUInteger day = indexPath.item - self.daysInWeek;
    dateComponents.day += day;
    NSDate *date = [self.calendar dateFromComponents:dateComponents];
    dateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                                      fromDate:date];
    NSDateComponents *nextDayComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                                                           fromDate:firstDateInMonth];
    nextDayComponents.day += day + 1;
    nextDayComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                                         fromDate:[self.calendar dateFromComponents:nextDayComponents]];
    
    NSDateComponents *monthComponents = [self.calendar components:NSMonthCalendarUnit fromDate:monthDate];
    cell.date = date;
    cell.month = monthDate;
    cell.weekday = dateComponents.weekday;
    cell.psuedoDate = monthComponents.month != dateComponents.month;
    cell.showsPsuedoDates = self.showsPsuedoDates;
    cell.dotColors = cell.psuedoDate ? nil : [self dotColorsForDate:date];
    cell.allDayAnnotations = cell.psuedoDate ? nil : [self allDayAnnotationsForDate:date];
    BOOL enabled;
    if (cell.psuedoDate) {
        enabled = self.showsPsuedoDates && [self dateEnabled:date];
        if (enabled) {
            BOOL concreteDateVisible = [self indexPathForConcreteDate:date] != nil;
            enabled = concreteDateVisible;
        }
    } else {
        enabled = [self dateEnabled:date];
    }
    cell.enabled = enabled;
    cell.drawRightSeparator = cell.psuedoDate && !self.showsPsuedoDates && nextDayComponents.day == 1;
    cell.titleLabel.text = [NSString stringWithFormat:@"%d", dateComponents.day];
    BOOL visible = !cell.psuedoDate || self.showsPsuedoDates;
    cell.drawBottomSeparator = drawBottomBorder || visible;
    cell.backgroundView.hidden = !visible;
    cell.contentView.hidden = !visible;
    [cell setNeedsDisplay];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldSelect = [self canSelectItemAtIndexPath:indexPath];
    if (!shouldSelect) {
        [self.collectionView selectItemAtIndexPath:[self concreteIndexPathFromIndexPath:indexPath] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        if ([self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
            [self.delegate calendarView:self didSelectDate:nil];
        }
    }
    return shouldSelect;
    //return [self canSelectItemAtIndexPath:indexPath];
}

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//#warning don't need this
//    BOOL shouldSelect = [self canSelectItemAtIndexPath:indexPath];
//    if (!shouldSelect) {
//        [self.collectionView selectItemAtIndexPath:[self concreteIndexPathFromIndexPath:indexPath] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
//        if ([self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
//            [self.delegate calendarView:self didSelectDate:nil];
//        }
//    }
//    return shouldSelect;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MNCalendarViewCell *cell = (MNCalendarViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    NSDate *selectedDate = nil;
    if ([cell isKindOfClass:MNCalendarViewDayCell.class] && cell.enabled) {
        MNCalendarViewDayCell *dayCell = (MNCalendarViewDayCell *)cell;
        
        if (dayCell.psuedoDate) {
            UICollectionViewScrollPosition scrollPosition = UICollectionViewScrollPositionCenteredVertically;
            [self.collectionView selectItemAtIndexPath:[self indexPathForConcreteDate:dayCell.date] animated:YES scrollPosition:scrollPosition];
        }
        selectedDate = dayCell.date;
    }
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [self.delegate calendarView:self didSelectDate:selectedDate];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width      = self.bounds.size.width;
    CGFloat itemWidth  = roundf(width / self.daysInWeek);
    CGFloat itemHeight = indexPath.item < self.daysInWeek ? 30.f : itemWidth;
    
    NSUInteger weekday = indexPath.item % self.daysInWeek;
    
    if (weekday == self.daysInWeek - 1) {
        itemWidth = width - (itemWidth * (self.daysInWeek - 1));
    }
    
    return CGSizeMake(itemWidth, itemHeight);
}

@end
