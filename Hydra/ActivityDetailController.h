//
//  ActivityDetailViewController.h
//  Hydra
//
//  Created by Pieter De Baets on 11/10/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Activity;

@protocol ActivityListDelegate <NSObject>

- (Activity *)activityBefore:(Activity *)current;
- (Activity *)activityAfter:(Activity *)current;
- (void)didSelectActivity:(Activity *)activity;

@end

@interface ActivityDetailController : UITableViewController

- (id)initWithActivity:(Activity *)activity delegate:(id<ActivityListDelegate>)delegate;

@end
