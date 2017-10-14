//
//  AssociationPreferenceController.m
//  Hydra
//
//  Created by Toon Willems on 07/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import "AssociationPreferenceController.h"
#import "Hydra-Swift.h"
#import <SVProgressHUD/SVProgressHUD.h>

@import SVProgressHUD;

@interface AssociationPreferenceController () <UISearchResultsUpdating>

@property (nonatomic, strong) NSArray *convents;
@property (nonatomic, strong) NSDictionary *associations;
@property (nonatomic, strong) NSMutableArray *filteredConvents;
@property (nonatomic, strong) NSMutableDictionary *filteredAssociations;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation AssociationPreferenceController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        [self loadAssociations];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Zoek een vereniging";
    self.tableView.tableHeaderView = self.searchController.searchBar;

    // Set UISearchBar button text, normally "Cancel"
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitle:@"OK"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Verenigingen";

    if (self.associations.count == 0) {
        [SVProgressHUD show];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track(@"Voorkeuren > Verenigingen");
    [SVProgressHUD dismiss];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PreferencesControllerDidUpdatePreference" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadAssociations
{
    NSArray *all = [[AssociationStore shared] associations];

    if (all.count > 0) {
        [SVProgressHUD dismiss];
    } else {
        [SVProgressHUD show];
    }
    
    // Get all unique parent organisations
    NSSet *convents = [NSSet setWithArray:[all valueForKey:@"parentAssociation"]];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    self.convents = [convents sortedArrayUsingDescriptors:@[sort]];
    self.filteredConvents = [self.convents mutableCopy];
    
    // Group by parentAssociation
    NSMutableDictionary *grouped = [[NSMutableDictionary alloc] init];
    sort = [NSSortDescriptor sortDescriptorWithKey:@"displayedFullName" ascending:YES];
    for (NSString *name in self.convents) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@",
                             @"parentAssociation", name];
        grouped[name] = [[all filteredArrayUsingPredicate:pred]
                         sortedArrayUsingDescriptors:@[sort]];
    }
    self.associations = grouped;
    self.filteredAssociations = [self.associations mutableCopy];
}

#pragma mark - Search Control Delegate
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    if (searchString.length > 0) {
        for(NSString *convent in [self.associations allKeys]) {
            NSPredicate *filter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return [evaluatedObject matches:searchString];
            }];
            self.filteredAssociations[convent] = [self.associations[convent] filteredArrayUsingPredicate:filter];

            // Remove convent from list if it does not have any items
            if ([self.filteredAssociations[convent] count] == 0) {
                [self.filteredConvents removeObject:convent];
            }
            // Check if convent with items is present
            else if (![self.filteredConvents containsObject:convent]) {
                [self.filteredConvents addObject:convent];
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
                NSArray *sorted = [self.filteredConvents sortedArrayUsingDescriptors:@[sort]];
                self.filteredConvents = [sorted mutableCopy];
            }
        }
    }
    else {
        self.filteredAssociations = [self.associations mutableCopy];
        self.filteredConvents = [self.convents mutableCopy];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *internalName;
    if (!self.searchController.isActive) {
        internalName = self.convents[section];
    }
    else {
        internalName = self.filteredConvents[section];
    }
    
    Association *association = [[AssociationStore shared] associationWithName:internalName];
    return association.displayName;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.searchController.isActive) {
        return self.convents.count;
    }
    else {
        return self.filteredConvents.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.searchController.isActive) {
        return [self.associations[self.convents[section]] count];
    }
    else {
        return [self.filteredAssociations[self.filteredConvents[section]] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AssociationPreferenceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    Association *association;
    if (!self.searchController.isActive) {
        NSString *convent = self.convents[indexPath.section];
        association = self.associations[convent][indexPath.row];
    }
    else {
        NSString *convent = self.filteredConvents[indexPath.section];
        association = self.filteredAssociations[convent][indexPath.row];
    }
    cell.textLabel.text = association.displayedFullName;

    NSArray *preferred = [PreferencesService sharedService].preferredAssociations;
    if ([preferred containsObject:association.internalName]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name;
    if (!self.searchController.isActive) {
        NSString *convent = self.convents[indexPath.section];
        name = [self.associations[convent][indexPath.row] internalName];
    }
    else {
        NSString *convent = self.filteredConvents[indexPath.section];
        name = [self.filteredAssociations[convent][indexPath.row] internalName];
    }
    
    PreferencesService *prefs = [PreferencesService sharedService];
    NSMutableArray *preferred = [prefs.preferredAssociations mutableCopy];
    if ([preferred containsObject:name]) {
        [preferred removeObject:name];
    }
    else {
        [preferred addObject:name];
    }
    prefs.preferredAssociations = preferred;
    
    [tableView reloadRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
