//
//  OWMissionViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMediaObjectViewController.h"
#import "OWMission.h"
#import "OWDashboardView.h"
#import "OWBannerView.h"
#import "BButton.h"

@interface OWMissionViewController : OWMediaObjectViewController

@property (nonatomic, strong) OWMission *mission;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *blurbLabel;
@property (nonatomic, strong) OWBannerView *bannerView;

@property (nonatomic, strong) BButton *joinButton;
@property (nonatomic, strong) BButton *leaveButton;
@property (nonatomic, strong) BButton *mapButton;
@property (nonatomic, strong) BButton *mediaButton;

@end
