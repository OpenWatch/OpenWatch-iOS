//
//  OWSettingsViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWDashboardView.h"
#import "OWRootViewController.h"

@interface OWSettingsViewController : OWRootViewController

@property (nonatomic, strong) OWDashboardView *dashboardView;

@end
