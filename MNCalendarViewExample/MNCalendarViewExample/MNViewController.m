//
//  MNViewController.m
//  MNCalendarViewExample
//
//  Created by Min Kim on 7/26/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNViewController.h"
#import "MNCalendarView/MNCalendarView.h"
#import "MNCalendarView/NSDate+MNAdditions.h"
#import "MNCalendarView/MNAnnotation.h"
#import "MNCalendarView/MNEventCalendarView.h"

@interface MNViewController () <MNEventCalendarViewDelegate, UITableViewDataSource>

@property(nonatomic,strong) NSCalendar     *calendar;
@property(nonatomic,strong) MNEventCalendarView *calendarView;
@property(nonatomic,strong) NSDate         *currentDate;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSArray *eventsForSelectedDate;

@end

@implementation MNViewController

- (instancetype)initWithCalendar:(NSCalendar *)calendar title:(NSString *)title {
  if (self = [super init]) {
    self.calendar = calendar;
    self.title = title;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = UIColor.whiteColor;
  
  self.currentDate = [NSDate date];
    NSDateComponents *components = [self.calendar components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self.currentDate];
    NSInteger currentMonth = components.month;
    NSInteger currentYear = components.year;
    
    CGFloat kTableViewHeight = 200;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - kTableViewHeight, CGRectGetWidth(self.view.bounds), kTableViewHeight) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];

  self.calendarView = [[MNEventCalendarView alloc] initWithFrame:self.view.bounds];
  self.calendarView.calendar = self.calendar;
  //self.calendarView.selectedDate = [NSDate date];
    //self.calendarView.showsPsuedoDates = YES;
  self.calendarView.eventDelegate = self;
  self.calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.calendarView.backgroundColor = UIColor.whiteColor;
    
    [self.calendarView addEvent:[MNTimeEvent timeEventWithStartTime:[NSDate mn_dateFromDay:10 month:currentMonth year:currentYear hour:5 minute:0]
                                                            endTime:[NSDate mn_dateFromDay:10 month:currentMonth year:currentYear hour:6 minute:0]
                                                           andColor:[UIColor blueColor]
                                                           userData:@"Event 1"]];
    [self.calendarView addEvent:[MNTimeEvent timeEventWithStartTime:[NSDate mn_dateFromDay:10 month:currentMonth year:currentYear hour:7 minute:0]
                                                            endTime:[NSDate mn_dateFromDay:10 month:currentMonth year:currentYear hour:8 minute:0]
                                                           andColor:[UIColor redColor]
                                                           userData:@"Event 2"]];
    [self.calendarView addEvent:[MNTimeEvent timeEventWithStartTime:[NSDate mn_dateFromDay:12 month:currentMonth year:currentYear hour:7 minute:0]
                                                            endTime:[NSDate mn_dateFromDay:12 month:currentMonth year:currentYear hour:8 minute:0]
                                                           andColor:[UIColor grayColor]
                                                           userData:@"Event 3"]];
    [self.calendarView addEvent:[MNDateEvent dateEventWithStartTime:[NSDate mn_dateFromDay:8 month:currentMonth year:currentYear]
                                                            endTime:[NSDate mn_dateFromDay:8 month:currentMonth year:currentYear]
                                                           andColor:[UIColor greenColor]
                                                           userData:@"Single day event"]];
    [self.calendarView addEvent:[MNDateEvent dateEventWithStartTime:[NSDate mn_dateFromDay:9 month:currentMonth year:currentYear]
                                                            endTime:[NSDate mn_dateFromDay:10 month:currentMonth year:currentYear]
                                                           andColor:[UIColor blueColor]
                                                           userData:@"2 day event"]];
    [self.calendarView addEvent:[MNDateEvent dateEventWithStartTime:[NSDate mn_dateFromDay:15 month:currentMonth year:currentYear]
                                                            endTime:[NSDate mn_dateFromDay:19 month:currentMonth year:currentYear]
                                                           andColor:[UIColor yellowColor]
                                                           userData:@"Week event"]];
    [self.calendarView addEvent:[MNDateEvent dateEventWithStartTime:[NSDate mn_dateFromDay:13 month:currentMonth year:currentYear]
                                                            endTime:[NSDate mn_dateFromDay:15 month:currentMonth year:currentYear]
                                                           andColor:[UIColor redColor]
                                                           userData:@""]];
    [self.calendarView addEvent:[MNDateEvent dateEventWithStartTime:[NSDate mn_dateFromDay:13 month:currentMonth year:currentYear]
                                                            endTime:[NSDate mn_dateFromDay:14 month:currentMonth year:currentYear]
                                                           andColor:[UIColor orangeColor]
                                                           userData:@""]];
    [self.calendarView addEvent:[MNDateEvent dateEventWithStartTime:[NSDate mn_dateFromDay:15 month:currentMonth year:currentYear]
                                                            endTime:[NSDate mn_dateFromDay:16 month:currentMonth year:currentYear]
                                                           andColor:[UIColor purpleColor]
                                                           userData:@""]];
    [self.calendarView addEvent:[MNDateEvent dateEventWithStartTime:[NSDate mn_dateFromDay:17 month:currentMonth year:currentYear]
                                                            endTime:[NSDate mn_dateFromDay:18 month:currentMonth year:currentYear]
                                                           andColor:[UIColor greenColor]
                                                           userData:@""]];
    [self.calendarView addEvent:[MNDateEvent dateEventWithStartTime:[NSDate mn_dateFromDay:16 month:currentMonth year:currentYear]
                                                            endTime:[NSDate mn_dateFromDay:16 month:currentMonth year:currentYear]
                                                           andColor:[UIColor brownColor]
                                                           userData:@""]];
    [self.calendarView addEvent:[MNDateEvent dateEventWithStartTime:[NSDate mn_dateFromDay:17 month:currentMonth year:currentYear]
                                                            endTime:[NSDate mn_dateFromDay:17 month:currentMonth year:currentYear]
                                                           andColor:[UIColor blueColor]
                                                           userData:@""]];
    
  
  [self.view addSubview:self.calendarView];
    [self.view bringSubviewToFront:self.tableView];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [self.calendarView.collectionView.collectionViewLayout invalidateLayout];
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [self.calendarView reloadData];
}

#pragma mark - MNEventCalendarViewDelegate

- (void)eventCalendarView:(MNEventCalendarView *)eventCalendarView didSelectDate:(NSDate *)date withEvents:(NSArray *)events {
    NSLog(@"Date selected: %@", date);
    for (MNEvent *event in events) {
        NSLog(@"%@", [event debugDescription]);
    }
    self.eventsForSelectedDate = events;
    self.tableView.hidden = !date || events.count == 0;
    //CGRect height = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    //CGRect heightWithTableView = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.tableView.bounds));
    CGFloat bottomInset = self.tableView.hidden ? 0 : CGRectGetHeight(self.tableView.bounds);
    self.calendarView.collectionView.contentInset = UIEdgeInsetsMake(0, 0, bottomInset, 0);
    self.calendarView.collectionView.showsVerticalScrollIndicator = YES;
#warning TODO: this is really slow to update the frame
    //self.calendarView.frame = self.tableView.hidden ? height : heightWithTableView;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.eventsForSelectedDate.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * const kCellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    }
    MNEvent *event = self.eventsForSelectedDate[indexPath.item];
    NSString *name = event.userData;
    cell.textLabel.text = name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", event.startTime, event.endTime];
    return cell;
}

@end
