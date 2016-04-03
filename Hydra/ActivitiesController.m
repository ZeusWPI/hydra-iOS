//
//  ActivityViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "ActivitiesController.h"
#import "Hydra-Swift.h"
#import "NSDate+Utilities.h"
#import "ActivityDetailController.h"
#import "NSDateFormatter+AppLocale.h"
#import "PreferencesService.h"
#import "RMPickerViewController.h"
#import "Hydra-Swift.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface ActivitiesController () <ActivityListDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, assign) BOOL activitiesUpdated;

@property (nonatomic, strong) NSArray *days;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSArray *oldDays;
@property (nonatomic, strong) NSDictionary *oldData;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSUInteger previousSearchLength;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UIPickerView *datePicker;

@end

@implementation ActivitiesController

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.count = 0;
        [self loadActivities];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(activitiesUpdated:)
                       name:@"AssociationStoreDidUpdateActivitiesNotification" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Activiteiten";

    // Switch dates using the calendar icon
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-calendar.png"]
                                                            style:UIBarButtonItemStylePlain
                                                           target:self action:@selector(dateButtonTapped:)];
    btn.enabled = self.days.count > 0;
    self.navigationItem.rightBarButtonItem = btn;

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;

    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    if ([UIRefreshControl class]) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor hydraTintColor];
        [refreshControl addTarget:self action:@selector(didPullRefreshControl:)
                 forControlEvents:UIControlEventValueChanged];

        self.refreshControl = refreshControl;
    }
    
    UINib *nib = [UINib nibWithNibName:@"ActivityOverviewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ActivityOverviewCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Make sure we scroll with any selection that may have been set
    [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:NO];

    // Call super last, as it will clear the selection
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Activities");

    // Show loading indicator when no content is found yet
    if (self.days.count == 0 && !self.activitiesUpdated) {
        [SVProgressHUD show];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)didPullRefreshControl:(id)sender
{
    [[AssociationStore sharedStore] reloadActivities:YES];
}

- (void)loadActivities
{
    NSArray *activities = [AssociationStore sharedStore].activities;

    // Filter activities
    PreferencesService *prefs = [PreferencesService sharedService];
    if (prefs.filterAssociations) {
        NSArray *associations = prefs.preferredAssociations;
        NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {
            return [associations containsObject:[obj association].internalName] ||
                   [obj highlighted];
        }];
        activities = [activities filteredArrayUsingPredicate:pred];
    }

    // Group activities by day
    NSDate *now = [NSDate date];
    NSMutableDictionary *groups = [[NSMutableDictionary alloc] init];

    for (Activity *activity in activities) {
        NSDate *day = [activity.start dateAtStartOfDay];

        // Check that activity is not over yet
        if (!activity.end || [activity.end isEarlierThanDate:now]) continue;

        NSMutableArray *group = groups[day];
        if (!group) {
            groups[day] = group = [[NSMutableArray alloc] init];
        }
        [group addObject:activity];
    }

    self.days = [[groups allKeys] sortedArrayUsingSelector:@selector(compare:)];

    // Sort activities per day
    for (NSDate *date in self.days) {
        groups[date] = [groups[date] sortedArrayUsingComparator:
                            ^(Activity *obj1, Activity *obj2) {
                                return [obj1.start compare:obj2.start];
                            }];
    }

    self.data = groups;
    self.navigationItem.rightBarButtonItem.enabled = self.days.count > 0;
    [self.tableView reloadData];
}

- (void)activitiesUpdated:(NSNotification *)notification
{
    self.activitiesUpdated = YES;

    [self loadActivities];
    [self.tableView reloadData];

    // Hide or update HUD
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }

    if ([UIRefreshControl class]) {
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.days.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate *date = self.days[section];
    return [self.data[date] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter H_dateFormatterWithAppLocale];
        dateFormatter.dateFormat = @"E d MMMM";
    }
    return [dateFormatter stringFromDate:self.days[section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = self.days[indexPath.section];
    Activity *activity = self.data[date][indexPath.row];
    static NSString *CellIdentifier = @"ActivityOverviewCell";
    ActivityOverviewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    cell.activity = activity;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = self.days[indexPath.section];
    Activity *activity = self.data[date][indexPath.row];
    ActivityDetailController *detailViewController = [[ActivityDetailController alloc]
                                                          initWithActivity:activity delegate:self];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - Searchbar delegate

- (void)willPresentSearchController:(UISearchController *)searchController
{
    self.oldDays = [[NSArray alloc] initWithArray:self.days copyItems:YES];
    self.oldData = [[NSDictionary alloc] initWithDictionary:self.data copyItems:YES];
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    self.data = self.oldData;
    self.days = self.oldDays;
    self.previousSearchLength = 0;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self filterActivities];
    [self.tableView reloadData];
}

- (void) filterActivities
{
    NSString *searchString = self.searchController.searchBar.text;
    if (searchString.length == 0) {
        self.days = self.oldDays;
        self.data = self.oldData;
        self.previousSearchLength = 0;
    }
    else {
        if (self.previousSearchLength > searchString.length){
            self.days = self.oldDays;
            self.data = self.oldData;
        }
        
        self.previousSearchLength = searchString.length;
        
        NSMutableArray *filteredDays = [[NSMutableArray alloc] init];
        NSMutableDictionary *filteredData = [[NSMutableDictionary alloc] init];
        
        for (NSDate *day in self.days) {
            NSMutableArray *activities = self.data[day];
            NSMutableArray *filteredActivities = [[NSMutableArray alloc] init];
            for (Activity *activity in activities) {
                if ([self filterActivity:activity fromString:searchString]) {
                    [filteredActivities addObject:activity];
                }
            }
            if (filteredActivities.count > 0){
                [filteredDays addObject:day];
                filteredData[day] = filteredActivities;
            }
        }
        self.days = filteredDays;
        self.data = filteredData;
    }
}

- (BOOL) filterActivity:(Activity*)activity fromString:(NSString*)searchString
{
    NSStringCompareOptions option = NSCaseInsensitiveSearch;
    if ([activity.title rangeOfString:searchString options:option].location != NSNotFound ||
        [activity.association.internalName rangeOfString:searchString options:option].location != NSNotFound) {
        return YES;
    }

    if (activity.association.fullName && [activity.association.fullName rangeOfString:searchString options:option].location != NSNotFound) {
        return YES;
    }
    /*if (![activity.categories  isEqual: @[[NSNull null]]]) {
        for(NSString* categorie in activity.categories){
            if([categorie rangeOfString:searchString options:option].location != NSNotFound){
                return YES;
            }
        }
    }*/ //TODO: ask Michael if categories are ever coming back
    return NO;
}

#pragma mark - Activy list delegate

- (Activity *)activityBefore:(Activity *)current
{
    NSDate *day = [current.start dateAtStartOfDay];
    NSUInteger index = [self.data[day] indexOfObject:current];
    if (index == NSNotFound) return nil;

    // Is there another activity in the same day?
    if (index > 0) {
        return self.data[day][index - 1];
    }

    // Is there another day we can find activities in
    NSUInteger dayIndex = [self.days indexOfObject:day];
    if (dayIndex == 0 || dayIndex == NSNotFound) return nil;
    else {
        // Assuming each category has at least one date
        NSDate *prevDay = self.days[dayIndex - 1];
        return [self.data[prevDay] lastObject];
    }
}

- (Activity *)activityAfter:(Activity *)current
{
    NSDate *day = [current.start dateAtStartOfDay];
    NSUInteger index = [self.data[day] indexOfObject:current];
    if (index == NSNotFound) return nil;

    // Is there another activity in the same day?
    if (index < [self.data[day] count] - 1) {
        return self.data[day][index + 1];
    }

    // Is there another day we can find activities in
    NSUInteger dayIndex = [self.days indexOfObject:day];
    if (dayIndex == self.days.count - 1 || dayIndex == NSNotFound) return nil;
    else {
        // Assuming each category has at least one date
        NSDate *nextDay = self.days[dayIndex + 1];
        return self.data[nextDay][0];
    }
}

- (void)didSelectActivity:(Activity *)activity
{
    NSDate *day = [activity.start dateAtStartOfDay];
    NSUInteger section = [self.days indexOfObject:day];
    NSUInteger row = [self.data[day] indexOfObject:activity];

    if (row != NSNotFound) {
        NSIndexPath *selection = [NSIndexPath indexPathForRow:row inSection:section];
        [self.tableView selectRowAtIndexPath:selection animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - Date button and UIPickerView

- (void)dateButtonTapped:(id)sender
{
    RMAction *action = [RMAction actionWithTitle:@"Kies" style: RMActionStyleDone andHandler:^(RMActionController * _Nonnull controller) {
        UIPickerView *picker = ((RMPickerViewController *)controller).picker;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[picker selectedRowInComponent:0]];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }];
    RMPickerViewController *pickerVC = [RMPickerViewController actionControllerWithStyle:RMActionControllerStyleWhite];
    pickerVC.picker.delegate = self;
    pickerVC.picker.dataSource = self;

    [pickerVC addAction: action];

    UIPickerView *picker = pickerVC.picker;
    NSInteger row = ((NSIndexPath *)[self.tableView indexPathsForVisibleRows][0]).section;
    [picker selectRow:row inComponent:0 animated:NO];

    if (self.tabBarController != nil) {
        [self.tabBarController presentViewController:pickerVC animated:YES completion:nil];
    } else {
        [self presentViewController:pickerVC animated:YES completion:nil];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.days.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label;
    if (!view) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 37)];
        label.font = [UIFont boldSystemFontOfSize:18];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
    }
    else {
        label = (UILabel *)view;
    }

    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [NSDateFormatter H_dateFormatterWithAppLocale];
        formatter.dateFormat = @"EEEE d MMMM";
    }
    label.text = [formatter stringFromDate:self.days[row]];

    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:row];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)dismissActionSheet:(id)sender
{
    UIActionSheet *sheet = (UIActionSheet *)[self.datePicker superview];
    [sheet dismissWithClickedButtonIndex:0 animated:YES];
    self.datePicker = nil;
}
@end
