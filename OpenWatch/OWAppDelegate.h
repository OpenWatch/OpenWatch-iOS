//
//  OWAppDelegate.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWHomeScreenViewController.h"
#import "BrowserViewController.h"
#import "OWLocationController.h"
#import "OWDashboardViewController.h"

#define OW_APP_DELEGATE ((OWAppDelegate*)[UIApplication sharedApplication].delegate)

@interface OWAppDelegate : UIResponder <UIApplicationDelegate, BrowserViewDelegate>

@property (nonatomic, strong) OWLocationController *locationController;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) OWHomeScreenViewController *homeScreen;
@property (nonatomic, strong) OWDashboardViewController *dashboardViewController;
@property (nonatomic, strong) UINavigationController *navigationController;

@end
