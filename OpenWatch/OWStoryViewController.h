//
//  OWStoryViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/14/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWStoryViewController : UIViewController

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *blurbLabel;
@property (nonatomic, strong) UITextView *bodyTextView;

@property (nonatomic, strong) NSManagedObjectID *storyObjectID;

@end
