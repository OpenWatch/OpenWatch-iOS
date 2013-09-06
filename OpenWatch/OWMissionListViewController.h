//
//  OWMissionListViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/28/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWPaginatedTableViewController.h"
#import "OWTooltipView.h"
#import "OWOnboardingView.h"
#import "OWLocationController.h"

@interface OWMissionListViewController : OWPaginatedTableViewController <OWTooltipViewDelegate, OWOnboardingViewDelegate, OWLocationControllerDelegate>

@property (nonatomic, strong) OWTooltipView *headerView;

@property (nonatomic, strong) OWOnboardingView *onboardingView;


@end
