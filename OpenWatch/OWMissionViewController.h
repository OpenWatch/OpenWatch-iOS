//
//  OWMissionViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMediaObjectViewController.h"
#import "OWMission.h"

@interface OWMissionViewController : OWMediaObjectViewController

@property (nonatomic, strong) OWMission *mission;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *blurbLabel;


@end
