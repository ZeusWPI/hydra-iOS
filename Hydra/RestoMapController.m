//
//  RestoMapController.m
//  Hydra
//
//  Created by Feliciaan De Palmenaer on 27/12/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "RestoMapController.h"
#import "Hydra-Swift.h"
#import "UINavigationController+ReplaceController.h"

@interface RestoMapController () <UISearchResultsUpdating, UITableViewDataSource,
    UITableViewDelegate>

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) NSArray *mapItems;
@property (nonatomic, strong) NSArray *filteredMapItems;
@property (nonatomic, strong) NSMutableDictionary *distances;

@property (nonatomic, assign) BOOL endingSearch;

@end

@implementation RestoMapController

#pragma mark Setting up the view & viewcontroller

- (id)init
{
    if (self = [super init]) {
        // Register for updates
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(loadMapItems)
                       name:@"RestoStoreDidUpdateInfoNotification" object:nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    // Create table view controller for search
    UITableViewController *tableVC = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableVC.tableView.delegate = self;
    tableVC.tableView.dataSource = self;

    // Create search controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:tableVC];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.placeholder = @"Zoek een resto";
    [self.view addSubview:self.searchController.searchBar];

    /*// Offset map frame a little bit
    CGRect mapFrame = self.mapView.frame;
    mapFrame.origin.y = 44;
    self.mapView.frame = mapFrame;*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Resto Map";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Resto Map");
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)mapLocationUpdated
{
    if (self.searchController.isActive) {
        [self calculateDistances];
        [[(UITableViewController *)[[self searchController] searchResultsController] tableView] reloadData];
    }
}

#pragma mark - Data

- (void)loadMapItems
{
    [self.mapView removeAnnotations:self.mapItems];
    self.mapItems = [RestoStore sharedStore].locations;
    [self.mapView addAnnotations:self.mapItems];

    [self filterMapItems];
}

- (void)calculateDistances
{
    CLLocation *user = self.mapView.userLocation.location;
    NSMutableDictionary *distances = [NSMutableDictionary dictionaryWithCapacity:self.mapItems.count];
    for (RestoLocation *resto in self.mapItems) {
        CLLocation *coordinate = [[CLLocation alloc] initWithLatitude:resto.coordinate.latitude
                                                           longitude:resto.coordinate.longitude];
        CLLocationDistance distance = [user distanceFromLocation:coordinate];
        distances[resto.title] = @(distance);
    }
    self.distances = distances;

    [self reorderMapItems];
}

- (void)filterMapItems
{
    NSString *searchString = self.searchController.searchBar.text;
    if (searchString.length == 0) {
        self.filteredMapItems = self.mapItems;
    }
    else {
        NSMutableArray *filteredItems = [[NSMutableArray alloc] init];
        for (RestoLocation *resto in self.mapItems) {
            NSRange r = [resto.title rangeOfString:searchString options:NSCaseInsensitiveSearch];
            if (r.location != NSNotFound) {
                [filteredItems addObject:resto];
            }
        }
        self.filteredMapItems = filteredItems;
    }

    [self reorderMapItems];
    [[(UITableViewController *)[[self searchController] searchResultsController] tableView] reloadData];
}

- (void)reorderMapItems
{
    self.filteredMapItems = [self.filteredMapItems sortedArrayUsingComparator:^(id a, id b) {
        NSNumber *distA = self.distances[[a title]];
        NSNumber *distB = self.distances[[b title]];
        return [distA compare:distB];
    }];
}

#pragma mark - MapView delegate

- (void)resetMapViewRect
{
    // Hardcoded rectangle for the central resto's, so the default map is a nice overview
    MKMapRect defaultRect = MKMapRectMake(13.6974e+7, 8.9796e+7, 30e3, 45e3);
    [self.mapView setVisibleMapRect:defaultRect animated:NO];
}

#pragma mark - SearchController delegate
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    // Always show the searchResultsController when the searchBar is opened
    self.searchController.searchResultsController.view.hidden = NO;

    [self calculateDistances];
    [self filterMapItems];
}

#pragma mark - SearchController tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredMapItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RestoMapViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];

        cell.separatorInset = UIEdgeInsetsZero;
    }

    RestoLocation *resto = self.filteredMapItems[indexPath.row];
    cell.textLabel.text = resto.name;

    double distance = [self.distances[resto.name] doubleValue];
    if (distance == 0) {
        cell.detailTextLabel.text = @"";
    }
    else if (distance < 2000) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f m", distance];
    }
    else {
        distance /= 1000;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f km", distance];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Keep the search string
    NSString *search = self.searchController.searchBar.text;
    //[self.searchController setActive:NO animated:YES];
    [self.searchController dismissViewControllerAnimated:NO completion:nil];
    self.searchController.searchBar.text = search;

    // Highlight the selected item
    RestoLocation *selected = self.filteredMapItems[indexPath.row];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.012, 0.012);
    MKCoordinateRegion region = MKCoordinateRegionMake(selected.coordinate, span);
    [self.mapView setRegion:region animated:YES];
    [self.mapView selectAnnotation:selected animated:YES];
}

@end
