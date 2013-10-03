//
//  OWAppDelegate.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserViewController.h"
#import "OWLocationController.h"
#import "OWDashboardViewController.h"
#import "OWMediaCreationController.h"
#import "OWFeedViewController.h"
#import "OWFontManager.h"

@class PKRevealController;

#define OW_APP_DELEGATE ((OWAppDelegate*)[UIApplication sharedApplication].delegate)

@interface OWAppDelegate : UIResponder <UIApplicationDelegate, BrowserViewDelegate>

@property (nonatomic, strong, readwrite) PKRevealController *revealController;
@property (nonatomic, strong) OWFeedViewController *feedViewController;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, retain) NSTimer *backgroundTimer;

@property (nonatomic, strong) OWLocationController *locationController;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) OWDashboardViewController *dashboardViewController;
@property (nonatomic, strong) OWMediaCreationController *creationController;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) OWFontManager *fontManager;

@property (nonatomic) BOOL allowRotation;
@property (nonatomic) BOOL forceLandscapeRight;

@end
