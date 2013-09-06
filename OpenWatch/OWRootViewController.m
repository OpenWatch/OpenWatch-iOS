//
//  OWRootViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/21/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWRootViewController.h"
#import "OWUtilities.h"
#import "OWStrings.h"
#import "PKRevealController.h"
#import "OWAppDelegate.h"
#import "OWConstants.h"
#import "OWLoginViewController.h"

@interface OWRootViewController ()

@end

@implementation OWRootViewController
@synthesize badgeView, showBackButton;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [OWUtilities stoneBackgroundPattern];
        self.showBackButton = NO;
        [self setupNavBar];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedAccountPermissionsErrorNotification:) name:kAccountPermissionsError object:nil];

    }
    return self;
}

- (void) setupNavBar {
    self.title = WATCH_STRING;
    UIImage *revealImagePortrait = [UIImage imageNamed:@"reveal_menu_icon_portrait"];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake(0, 0, 45, 40);
    [button setImage:revealImagePortrait forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showLeftView:) forControlEvents:UIControlEventTouchUpInside];
    self.badgeView = [[OWMissionBadgeView alloc] initWithFrame:CGRectZero];
    badgeView.frame = CGRectMake(0, 0, 20, 20);
    self.badgeView.badgePositionAdjustment = CGPointMake(-7, 9);
    self.badgeView.badgeText = nil;
    [button addSubview:badgeView];
    UIBarButtonItem* leftItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    if (!showBackButton) {
        self.navigationItem.leftBarButtonItem = leftItem;
    } else {
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    }
    self.navigationItem.rightBarButtonItem = [OWUtilities barItemWithImage:[UIImage imageNamed:@"285-facetime-red.png"] target:self action:@selector(startRecording:)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self logoImage]];
    imageView.frame = CGRectMake(0, 0, 140, 25);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
}

- (UIImage*) logoImage {
    return [UIImage imageNamed:@"openwatch.png"];
}

- (void) showLeftView:(id)sender {
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController) {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    } else {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}

- (void) setShowBackButton:(BOOL)newShowBackButton {
    showBackButton = newShowBackButton;
    if (showBackButton) {
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    }
}


- (void) startRecording:(id)sender {
    [OW_APP_DELEGATE.creationController recordVideoFromViewController:self];
}

- (void) receivedAccountPermissionsErrorNotification:(NSNotification*)notification {
    [[Mixpanel sharedInstance] track:@"Account Permissions Error"];
    NSLog(@"%@ received", kAccountPermissionsError);
    [OW_APP_DELEGATE.navigationController popToRootViewControllerAnimated:YES];
    [self.revealController showViewController:self.revealController.frontViewController];
    OWLoginViewController *loginViewController = [[OWLoginViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    loginViewController.showCancelButton = NO;
    [OW_APP_DELEGATE.navigationController presentViewController:navController animated:YES completion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:WHOOPS_STRING message:SESSION_EXPIRED_STRING delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
        [alert show];
    }];
}


@end
