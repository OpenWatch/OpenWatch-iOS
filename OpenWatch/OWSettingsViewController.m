//
//  OWSettingsViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWSettingsViewController.h"
#import "OWStrings.h"
#import "OWLoginViewController.h"
#import "OWLocalMediaObjectListViewController.h"
#import "OWUtilities.h"
#import "OWShareController.h"
#import "OWProfileViewController.h"
#import "OWDashboardItem.h"
#import "OWSettingsController.h"

@interface OWSettingsViewController ()

@end

@implementation OWSettingsViewController
@synthesize dashboardView;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = SETTINGS_STRING;
        self.dashboardView = [[OWDashboardView alloc] initWithFrame:CGRectZero];
        
        
        
        OWDashboardItem *accountItem = [[OWDashboardItem alloc] initWithTitle:ACCOUNT_STRING image:nil target:self selector:@selector(accountButtonPressed:)];
        //OWDashboardItem *profileItem = [[OWDashboardItem alloc] initWithTitle:EDIT_PROFILE_STRING image:nil target:self selector:@selector(editProfilePressed:)];
        
        OWDashboardItem *shareItem = [[OWDashboardItem alloc] initWithTitle:SHARE_THIS_APP_STRING image:nil target:self selector:@selector(shareButtonPressed:)];
        
        OWDashboardItem *githubItem = [[OWDashboardItem alloc] initWithTitle:OPENWATCH_ON_GITHUB_STRING image:nil target:self selector:@selector(githubButtonPressed:)];
        
        OWDashboardItem *websiteItem = [[OWDashboardItem alloc] initWithTitle:VISIT_OPENWATCH_WEBSITE_STRING image:nil target:self selector:@selector(websiteButtonPressed:)];
        
        NSArray *profileItems = @[accountItem];
        
        NSArray *shareItems = @[shareItem, githubItem, websiteItem];
        
        self.dashboardView.dashboardItems = @[profileItems, shareItems];
    }
    return self;
}

- (void) editProfilePressed:(id)sender {
    OWProfileViewController *profile = [[OWProfileViewController alloc] init];
    profile.user = [OWSettingsController sharedInstance].account.user;
    [self.navigationController pushViewController:profile animated:YES];
}

- (void) accountButtonPressed:(id)sender {
    OWLoginViewController *loginView = [[OWLoginViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginView];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void) shareButtonPressed:(id)sender {
    [OWShareController shareURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/openwatch-social-muckraking/id642680756?ls=1&mt=8"] title:TWEET_OPENWATCH_STRING fromViewController:self];
}

- (void) githubButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/OpenWatch/OpenWatch-iOS"]];
}

- (void) websiteButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://openwatch.net/"]];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:dashboardView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dashboardView.frame = self.view.bounds;
    [TestFlight passCheckpoint:VIEW_SETTINGS_CHECKPOINT];
}

@end
