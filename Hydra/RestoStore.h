//
//  SchamperStore.h
//  Hydra
//
//  Created by Pieter De Baets on 17/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const RestoStoreDidReceiveMenuNotification;
extern NSString *const RestoStoreDidUpdateInfoNotification;

@class RestoMenu;

@interface RestoStore : NSObject

+ (RestoStore *)sharedStore;

- (RestoMenu *)menuForDay:(NSDate *)day;
- (NSArray*)locations;
- (NSArray*)legend;

@end