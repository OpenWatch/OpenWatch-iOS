//
//  OWHomeScreenViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/29/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWHomeScreenViewController.h"
#import "OWStrings.h"
#import "OWUtilities.h"
#import "OWLoginViewController.h"
#import "OWSettingsController.h"
#import "OWCaptureViewController.h"
#import "OWFeedViewController.h"
#import "OWShareController.h"
#import "OWAccountAPIClient.h"


#define RECORD_BUTTON_HEIGHT 131.0f
#define RECORD_BUTTON_WIDTH 150.0f
#define BUTTON_HEIGHT 80.0f
#define BUTTON_WIDTH 90.0f

@interface OWHomeScreenViewController ()
@end

@implementation OWHomeScreenViewController
@synthesize recordButtonView, watchButtonView, localButtonView, savedButtonView, settingsButtonView, gridView;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = OPENWATCH_STRING;
    }
    return self;
}





- (void) checkAccount {
    return;
    OWSettingsController *settingsController = [OWSettingsController sharedInstance];
    if (![settingsController.account isLoggedIn]) {
        OWLoginViewController *loginViewController = [[OWLoginViewController alloc] init];
        UINavigationController *loginNavController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [OWUtilities styleNavigationController:loginNavController];
        [self presentViewController:loginNavController animated:YES completion:^{
            
        }];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [TestFlight passCheckpoint:HOME_CHECKPOINT];
    CGFloat buttonHeight = BUTTON_HEIGHT;
    CGFloat buttonWidth = BUTTON_WIDTH;
    CGFloat recordButtonHeight = RECORD_BUTTON_HEIGHT;
    CGFloat recordButtonWidth = RECORD_BUTTON_WIDTH;
    
    CGFloat xPadding = 50.0f;
    CGFloat yPadding = 10.0f;
    
    CGFloat recordButtonYOrigin = 0.0f;
    
    self.recordButtonView.frame = CGRectMake(self.view.frame.size.width/2 - recordButtonWidth/2, recordButtonYOrigin, recordButtonWidth, recordButtonHeight);
    
    CGFloat firstButtonRowYOrigin = recordButtonYOrigin+recordButtonHeight + yPadding*5;
    gridView.frame = CGRectMake(xPadding, firstButtonRowYOrigin, self.view.frame.size.width-xPadding*2, self.view.frame.size.height - firstButtonRowYOrigin - yPadding*5);
    
    self.watchButtonView.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
    CGFloat secondButtonColumnXOrigin = gridView.frame.size.width - buttonWidth;
    self.localButtonView.frame = CGRectMake(secondButtonColumnXOrigin, 0, buttonWidth, buttonHeight);
    CGFloat secondButtonRowYOrigin = gridView.frame.size.height - buttonHeight;
    self.savedButtonView.frame = CGRectMake(0, secondButtonRowYOrigin, buttonWidth, buttonHeight);
    self.settingsButtonView.frame = CGRectMake(secondButtonColumnXOrigin, secondButtonRowYOrigin, buttonWidth, buttonHeight);
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkAccount];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
