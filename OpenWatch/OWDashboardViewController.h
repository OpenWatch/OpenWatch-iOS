//
//  OWDashboardViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWActionBarView.h"
#import "OWPaginatedTableViewController.h"
#import "OWOnboardingView.h"

@interface OWDashboardViewController : OWPaginatedTableViewController <OWActionBarViewDelegate, OWOnboardingViewDelegate>

@property (nonatomic, strong) OWActionBarView *actionBarView;
@property (nonatomic, strong) OWOnboardingView *onboardingView;

@end
