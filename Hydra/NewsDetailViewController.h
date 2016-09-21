//
//  NewsDetailViewController.h
//  Hydra
//
//  Created by Pieter De Baets on 6/02/13.
//  Copyright (c) 2013 Zeus WPI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsItem;

@interface NewsDetailViewController : UIViewController

- (id)initWithNewsItem:(NewsItem *)newsItem;

@end
