//
//  ActivityDetailViewController.m
//  Hydra
//
//  Created by Pieter De Baets on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "AssociationActivity.h"
#import "Association.h"
#import "NSDateFormatter+AppLocale.h"
#import "FacebookEvent.h"
#import "NSDate+Utilities.h"
#import "CustomTableViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#define kHeaderSection 0

#define kInfoSection 1
    #define kAssociationRow 0
    #define kDateRow 1
    #define kLocationRow 2
    #define kGuestsRow 3
    #define kDescriptionRow 4
    #define kUrlRow 5

#define kActionSection 2
    #define kRsvpActionRow 0
    #define kCalendarActionRow 1

#define kSupplementaryCellViewTag 601

@interface ActivityDetailViewController () <EKEventEditViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) AssociationActivity *activity;
@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) id<ActivityListDelegate> listDelegate;

@property (nonatomic, strong) UITextView *descriptionView;

@end

@implementation ActivityDetailViewController

- (id)initWithActivity:(AssociationActivity *)activity delegate:(id<ActivityListDelegate>)delegate
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.activity = activity;
        self.listDelegate = delegate;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(facebookEventUpdated:)
                       name:FacebookEventDidUpdateNotification object:nil];
        [self reloadData];
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
    self.title = @"Detail";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Fast navigation between activitities
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[
        [UIImage imageNamed:@"navigation-up"], [UIImage imageNamed:@"navigation-down"]]];
    [segmentedControl addTarget:self action:@selector(segmentTapped:)
               forControlEvents:UIControlEventValueChanged];
    segmentedControl.frame = CGRectMake(0, 0, 90, 30);
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.momentary = YES;
    [self enableSegments:segmentedControl];

    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    self.navigationItem.rightBarButtonItem = segmentBarItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    GAI_Track([@"Activity > " stringByAppendingString:self.activity.title]);
}

- (void)reloadData
{
    NSMutableArray *fields = [[NSMutableArray alloc] init];
    fields[kAssociationRow] = self.activity.association.displayedFullName;

    // Formatted date
    static NSDateFormatter *dateStartFormatter = nil;
    static NSDateFormatter *dateEndFormatter = nil;
    if (!dateStartFormatter || !dateEndFormatter) {
        dateStartFormatter = [NSDateFormatter H_dateFormatterWithAppLocale];
        dateStartFormatter.dateFormat = @"EEE d MMMM H:mm";
        dateEndFormatter = [NSDateFormatter H_dateFormatterWithAppLocale];
        dateEndFormatter.dateFormat = @"H:mm";
    }

    if (self.activity.end) {
        // Does the event span more than 24 hours?
        if ([[self.activity.start dateByAddingDays:1] isLaterThanDate:self.activity.end]) {
            fields[kDateRow] = [NSString stringWithFormat:@"%@ - %@",
                                [dateStartFormatter stringFromDate:self.activity.start],
                                [dateEndFormatter stringFromDate:self.activity.end]];
        }
        else {
            fields[kDateRow] = [NSString stringWithFormat:@"%@ -\n%@",
                                [dateStartFormatter stringFromDate:self.activity.start],
                                [dateStartFormatter stringFromDate:self.activity.end]];
        }
    }
    else {
        fields[kDateRow] = [dateStartFormatter stringFromDate:self.activity.start];
    }

    fields[kLocationRow] = self.activity.location ? self.activity.location : @"";

    FacebookEvent *fbEvent = self.activity.facebookEvent;
    if (fbEvent.valid) {
        NSString *guests = [NSString stringWithFormat:@"%d aanwezig", fbEvent.attendees];
        if (fbEvent.friendsAttending) {
            NSUInteger count = fbEvent.friendsAttending.count;
            guests = [guests stringByAppendingFormat:@", %d %@", count,
                      (count == 1 ? @"vriend" : @"vrienden")];
        }
        fields[kGuestsRow] = guests;
    }
    else {
        fields[kGuestsRow] = @"";
    }

    fields[kDescriptionRow] =  @"";
    fields[kUrlRow] = @"http://";

    self.fields = fields;

    // Trigger event reload
    [self.activity.facebookEvent update];

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section) {
        case kHeaderSection:
            return 1;

        case kInfoSection: {
            NSUInteger rows = 3;
            if (self.activity.descriptionText.length > 0) rows++;
            if (self.activity.url.length > 0) rows++;

            // Facebook info?
            FacebookEvent *fbEvent = self.activity.facebookEvent;
            if (fbEvent.valid) rows++;

            return rows;
        }

        case kActionSection: {
            FacebookEvent *fbEvent = self.activity.facebookEvent;
            return fbEvent.valid ? 2 : 1;
        }

        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set some defaults
    UIFont *font = [UIFont boldSystemFontOfSize:13];
    CGFloat width = tableView.frame.size.width - 125;
    CGFloat minHeight = 36, spacing = 20;

    // Determine text, possibility to override settings
    NSString *text = nil;

    NSUInteger row = [self virtualRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case kHeaderSection:
            text = self.activity.title;

            font = [UIFont boldSystemFontOfSize:20];
            width = tableView.frame.size.width - 40;
            spacing = 0;

            if (self.activity.facebookEvent.smallImageUrl) {
                minHeight = 70;
                width -= 70;
            }
            break;

        case kInfoSection:
            // TODO: Bug? This check should not be required, but sometimes
            // this method is called with an indexPath it cannot handle...
            ZAssert(row < self.fields.count, @"heightForRow should not be called "
                    "for unknown cells (%d,%d)", indexPath.row, row);
            if (row < self.fields.count) {
                text = self.fields[row];
            }

            if (row == kGuestsRow) {
                FacebookEvent *fbEvent = self.activity.facebookEvent;
                if (fbEvent.friendsAttending.count > 0) {
                    spacing += 40;
                }
            }
            else if (row == kDescriptionRow) {
                // Different calculation for UITextView
                if (self.descriptionView) {
                    return self.descriptionView.contentSize.height + 5;
                }
            }
            break;

        case kActionSection:
            minHeight = 40;
            if (row == kRsvpActionRow) {
                FacebookEvent *fbEvent = self.activity.facebookEvent;
                if (fbEvent.userRsvp != FacebookEventRsvpNone) {
                    return 48;
                }
            }
            break;
    }

    if (text) {
        CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];
        return MAX(minHeight, size.height + spacing);
    }
    else {
        return minHeight;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return (section == 2) ? 0 : 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [self virtualRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case kHeaderSection:
            return [self tableView:tableView headerCellForRowAtIndex:row];

        case kInfoSection:
            return [self tableView:tableView infoCellForRowAtIndex:row];

        case kActionSection:
            return [self tableView:tableView actionCellForRowAtIndex:row];

        default:
            return nil;
    }
}

- (NSUInteger)virtualRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kInfoSection) {
        NSUInteger row = indexPath.row;

        FacebookEvent *fbEvent = self.activity.facebookEvent;
        if (row >= kGuestsRow && !fbEvent.valid) row ++;

        if (row >= kDescriptionRow && self.activity.descriptionText.length == 0) row++;
        if (row >= kUrlRow && self.activity.url.length == 0) row++;

        ZAssert(row <= kUrlRow, @"Invalid virtual row number");

        return row;
    }
    else if (indexPath.section == kActionSection)
    {
        NSUInteger row = indexPath.row;
        FacebookEvent *fbEvent = self.activity.facebookEvent;
        if (row >= kRsvpActionRow && !fbEvent.valid) row += 1;
        return row;
    }
    else {
        return indexPath.row;
    }
}

#pragma mark - Creating cells and views

- (UITableViewCell *)tableView:(UITableView *)tableView headerCellForRowAtIndex:(NSUInteger)row
{
    static NSString *CellIdentifier = @"ActivityDetailHeaderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = [[UIView alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
    }
    else {
        cell.indentationLevel = 0;
        [cell.contentView viewWithTag:kSupplementaryCellViewTag].hidden = YES;
    }

    cell.textLabel.text = self.activity.title;

    // Show image?
    NSURL *url = self.activity.facebookEvent.smallImageUrl;
    if (url) {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kSupplementaryCellViewTag];
        if (!imageView) {
            // TODO: make this image tappable to view the full size
            CGRect imageRect = CGRectMake(-1, -1, 72, 72);
            imageView = [[UIImageView alloc] initWithFrame:imageRect];
            imageView.backgroundColor = [UIColor whiteColor];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = 5;
            imageView.layer.borderWidth = 1.2;
            imageView.layer.borderColor = [UIColor colorWithWhite:0.65 alpha:1].CGColor;
            imageView.tag = kSupplementaryCellViewTag;
            [cell.contentView addSubview:imageView];
        }
        else {
            imageView.hidden = NO;
        }

        [imageView setImageWithURL:url];
        cell.indentationLevel = 7; // inset text 70pt
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView infoCellForRowAtIndex:(NSUInteger)row
{
    static NSString *CellIdentifier = @"ActivityDetailInfoCell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                          reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:13];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        // Restore defaults
        cell.alignToTop = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 0;
        [[cell viewWithTag:kSupplementaryCellViewTag] removeFromSuperview];
    }

    cell.textLabel.text = @"";
    cell.detailTextLabel.text = self.fields[row];

    // Customize per row
    switch (row) {
        case kAssociationRow:
            cell.textLabel.text = @"Vereniging";
            break;

        case kDateRow:
            cell.textLabel.text = @"Datum";
            break;

        case kLocationRow:
            // TODO: make the location go to a seperate view with just a map
            cell.textLabel.text = @"Locatie";
            if (self.activity.latitude != 0 && self.activity.longitude != 0) {
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            }
            break;

        case kGuestsRow: {
            cell.textLabel.text = @"Gasten";
            cell.alignToTop = YES;
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

            FacebookEvent *event = self.activity.facebookEvent;
            if (event.friendsAttending.count > 0) {
                UIView *friends = [self createFriendsView:event.friendsAttending];
                friends.frame = CGRectOffset(friends.frame, 83, cell.frame.size.height - 42);
                friends.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                friends.tag = kSupplementaryCellViewTag;
                [cell.contentView addSubview:friends];
            }
        } break;

        case kDescriptionRow:
            if (!self.descriptionView) {
                UITextView *descriptionView = [[UITextView alloc] init];
                descriptionView.autoresizingMask = UIViewAutoresizingFlexibleWidth
                                                 | UIViewAutoresizingFlexibleHeight;
                descriptionView.backgroundColor = [UIColor clearColor];
                descriptionView.bounces = NO;
                descriptionView.dataDetectorTypes = UIDataDetectorTypeLink
                                                  | UIDataDetectorTypePhoneNumber;
                descriptionView.editable = NO;
                descriptionView.font = [UIFont systemFontOfSize:13];
                descriptionView.tag = kSupplementaryCellViewTag;
                descriptionView.scrollEnabled = NO;
                self.descriptionView = descriptionView;

                // Reload row so the new size is applied
                [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
            }
            self.descriptionView.text = self.activity.descriptionText;
            self.descriptionView.frame = cell.contentView.bounds;
            [cell.contentView addSubview:self.descriptionView];
            break;

        case kUrlRow:
            cell.textLabel.text = @"Meer info";
            cell.detailTextLabel.text = self.activity.url;
            cell.detailTextLabel.numberOfLines = 1;
            cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;

            UIImage *linkImage = [UIImage imageNamed:@"external-link"];
            UIImage *highlightedLinkImage = [UIImage imageNamed:@"external-link-active"];
            UIImageView *linkAccessory = [[UIImageView alloc] initWithImage:linkImage
                                                           highlightedImage:highlightedLinkImage];
            linkAccessory.contentMode = UIViewContentModeScaleAspectFit;
            cell.accessoryView = linkAccessory;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            break;
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView actionCellForRowAtIndex:(NSUInteger)row
{
    static NSString *CellIdentifier = @"ActivityDetailButtonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.textColor = [UIColor H_detailLabelTextColor];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    else {
        [[cell viewWithTag:kSupplementaryCellViewTag] removeFromSuperview];
    }

    FacebookEvent *event = self.activity.facebookEvent;
    if (row == kRsvpActionRow) {
        if (!event.userRsvp || event.userRsvp == FacebookEventRsvpNone) {
            cell.textLabel.text = @"Bevestig aanwezigheid";
        }
        else {
            cell.textLabel.text = @"Aanwezigheid wijzigen\n ";
            NSString *detailLabelText = [NSString stringWithFormat:@"Momenteel sta je op '%@'",
                                         FacebookEventRsvpAsLocalizedString(event.userRsvp)];
            CGRect detailFrame = CGRectMake(0, 24, cell.contentView.bounds.size.width, 16);
            UILabel *detailLabel = [[UILabel alloc] initWithFrame:detailFrame];
            detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            detailLabel.backgroundColor = [UIColor clearColor];
            detailLabel.font = [UIFont systemFontOfSize:13];
            detailLabel.text = detailLabelText;
            detailLabel.textAlignment = UITextAlignmentCenter;
            detailLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
            detailLabel.highlightedTextColor = [UIColor colorWithWhite:0.8 alpha:1];
            detailLabel.tag = kSupplementaryCellViewTag;
            [cell.contentView addSubview:detailLabel];
        }
    }
    else if (row == kCalendarActionRow) {
        cell.textLabel.text = @"Toevoegen aan agenda";
    }

    return cell;
}

- (UIView *)createFriendsView:(NSArray *)friends
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 170, 30)];

    CGRect pictureFrame = CGRectMake(0, 0, 30, 30);
    UIImage *placeholder = [UIImage imageNamed:@"FacebookSDKResources.bundle/"
                                                "FBProfilePictureView/images/"
                                                "fb_blank_profile_square.png"];

    for (NSUInteger i = 0; i < friends.count && i < 5; i++) {
        UIImageView *image = [[UIImageView alloc] initWithFrame:pictureFrame];
        image.layer.masksToBounds = YES;
        image.layer.cornerRadius = 5;
        [image setImageWithURL:[friends[i] photoUrl] placeholderImage:placeholder];
        [container addSubview:image];

        pictureFrame.origin.x += 35;
    }

    return container;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [self virtualRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case kInfoSection:
            if (row == kUrlRow) {
                NSURL *url = [NSURL URLWithString:self.activity.url];
                [[UIApplication sharedApplication] openURL:url];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            break;

        case kActionSection:
            if (row == kRsvpActionRow) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Bevestig aanwezigheid" delegate:self
                                              cancelButtonTitle:@"Annuleren" destructiveButtonTitle:nil
                                              otherButtonTitles:@"Aanwezig", @"Misschien", @"Niet aanwezig", nil];
                [actionSheet showInView:self.view];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            else if (row == kCalendarActionRow) {
                [self addEventToCalendar];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            break;
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kInfoSection) {
        NSUInteger row = [self virtualRowAtIndexPath:indexPath];
        if (row == kGuestsRow) {
            [self.activity.facebookEvent showExternally];
        }
        else if (row == kLocationRow) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.activity.latitude,
                                                                           self.activity.longitude);
            // Create MKMapItem out of coordinates
            MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
            MKMapItem *destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
            destination.name = self.activity.location;

            // Use native maps on iOS6 or open Google Maps on iOS5
            if ([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)]) {
                [destination openInMapsWithLaunchOptions:nil];
            }
            else {
                NSString *url = [NSString stringWithFormat: @"http://maps.apple.com/maps?ll=%f,%f",
                                 self.activity.latitude, self.activity.longitude];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        }
    }
}

- (void)addEventToCalendar
{
    EKEventStore *store = [[EKEventStore alloc] init];
    if ([store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (!granted) return;
            [self performSelectorOnMainThread:@selector(addEventWithCalendarStore:)
                                   withObject:store waitUntilDone:NO];
        }];
    }
    else {
        [self addEventWithCalendarStore:store];
    }
}

- (void)addEventWithCalendarStore:(EKEventStore *)store
{
    EKEvent *event  = [EKEvent eventWithEventStore:store];
    event.title     = self.activity.title;
    event.location  = self.activity.location;
    event.startDate = self.activity.start;
    event.endDate   = self.activity.end;

    [event setCalendar:[store defaultCalendarForNewEvents]];

    EKEventEditViewController *eventViewController = [[EKEventEditViewController alloc] init];

    eventViewController.event = event;
    eventViewController.eventStore = store;
    eventViewController.editViewDelegate = self;
    [self.navigationController presentModalViewController:eventViewController animated:YES];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex <= 3) {
        // TODO: show some kind of spinner to indicate activity
        FacebookEventRsvp answer = buttonIndex + 1;
        self.activity.facebookEvent.userRsvp = answer;
    }
}

#pragma mark - Segmented control

- (void)enableSegments:(UISegmentedControl *)control
{
    AssociationActivity *prev = [self.listDelegate activityBefore:self.activity];
    [control setEnabled:(prev != nil) forSegmentAtIndex:0];
    AssociationActivity *next = [self.listDelegate activityAfter:self.activity];
    [control setEnabled:(next != nil) forSegmentAtIndex:1];
}

- (void)segmentTapped:(UISegmentedControl *)control
{
    if (control.selectedSegmentIndex == 0) {
        self.activity = [self.listDelegate activityBefore:self.activity];
    }
    else {
        self.activity = [self.listDelegate activityAfter:self.activity];
    }

    [self reloadData];
    [self enableSegments:control];
    [self viewDidAppear:NO]; // Trigger analytics
    [self.listDelegate didSelectActivity:self.activity];
}

#pragma mark - Notifications

- (void)facebookEventUpdated:(NSNotification *)notification
{
    [self reloadData];
}

@end
