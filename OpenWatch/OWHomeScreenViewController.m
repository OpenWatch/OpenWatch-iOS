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
#import "OWSettingsViewController.h"

@interface OWHomeScreenViewController ()
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *newsButton;
@property (nonatomic, strong) UIButton *helpButton;
@end

@implementation OWHomeScreenViewController
@synthesize recordButton, newsButton, helpButton;

- (id)init
{
    self = [super init];
    if (self) {
        self.recordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.newsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.helpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear-white.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(settingsButtonPressed:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [OWUtilities fabricBackgroundPattern];
    [recordButton setTitle:RECORD_STRING forState:UIControlStateNormal];
    [newsButton setTitle:WATCH_STRING forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(recordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [newsButton addTarget:self action:@selector(newsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordButton];
    [self.view addSubview:newsButton];
}


- (void) checkAccount {
    OWLoginViewController *loginViewController = [[OWLoginViewController alloc] init];
    UINavigationController *loginNavController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    OWSettingsController *settingsController = [OWSettingsController sharedInstance];
    if (![settingsController.account isLoggedIn]) {
        [self presentViewController:loginNavController animated:YES completion:^{
            
        }];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat recordButtonYOrigin = 50.0f;
    CGFloat xPadding = 20.0f;
    CGFloat yPadding = 20.0f;
    CGFloat buttonHeight = 100.0f;
    CGFloat buttonWidth = self.view.frame.size.width-xPadding*2;
    self.recordButton.frame = CGRectMake(xPadding, recordButtonYOrigin, buttonWidth, buttonHeight);
    self.newsButton.frame = CGRectMake(xPadding, recordButtonYOrigin+buttonHeight + yPadding, buttonWidth, buttonHeight);
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

- (void) settingsButtonPressed:(id)sender {
    OWSettingsViewController *settingsView = [[OWSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsView animated:YES];
}

- (void) recordButtonPressed:(id)sender {
    OWCaptureViewController *captureView = [[OWCaptureViewController alloc] init];
    UINavigationController *captureNav = [[UINavigationController alloc] initWithRootViewController:captureView];
    [self presentViewController:captureNav animated:YES completion:^{
    }];
}

- (void) newsButtonPressed:(id)sender {
    
}

@end
