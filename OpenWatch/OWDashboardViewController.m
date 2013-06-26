//
//  OWDashboardViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWDashboardViewController.h"
#import "OWUtilities.h"
#import "OWCaptureViewController.h"
#import "OWAccountAPIClient.h"
#import "OWLoginViewController.h"
#import "OWSettingsViewController.h"
#import "OWLocalMediaObjectListViewController.h"
#import "OWStrings.h"
#import "OWFeedViewController.h"
#import "OWInvestigationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "OWSettingsController.h"
#import "OWFeedViewController.h"
#import "OWDashboardItem.h"
#import "OWPhoto.h"
#import "OWLocationController.h"
#import "OWLocalMediaEditViewController.h"
#import "OWAppDelegate.h"
#import "OWShareController.h"
#import "UserVoice.h"
#import "OWStyleSheet.h"
#import "OWAPIKeys.h"
#import "OWConstants.h"
#import "OWMissionListViewController.h"
#import "OWMission.h"
#import "OWBadgedDashboardItem.h"
#import "PKRevealController.h"
#import "OWTag.h"
#import "OWTagDashboardItem.h"

#define kActionBarHeight 70.0f


@interface OWDashboardViewController ()

@end

@implementation OWDashboardViewController
@synthesize dashboardView, staticDashboardItems;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setupStaticDashboardItems {
    OWDashboardItem *topStories = [[OWDashboardItem alloc] initWithTitle:TOP_STORIES_STRING image:[UIImage imageNamed:@"28-star.png"] target:self selector:@selector(feedButtonPressed:)];
    OWDashboardItem *local = [[OWDashboardItem alloc] initWithTitle:LOCAL_FEED_STRING image:[UIImage imageNamed:@"193-location-arrow.png"] target:self selector:@selector(localFeedButtonPressed:)];
    OWDashboardItem *yourMedia = [[OWDashboardItem alloc] initWithTitle:YOUR_MEDIA_STRING image:[UIImage imageNamed:@"160-voicemail-2.png"] target:self selector:@selector(yourMediaPressed:)];
    OWDashboardItem *rawFeed = [[OWDashboardItem alloc] initWithTitle:@"Raw Feed" image:[UIImage imageNamed:@"46-movie-2.png"] target:self selector:@selector(rawFeedPressed:)];
    
    OWDashboardItem *feedback = [[OWDashboardItem alloc] initWithTitle:SEND_FEEDBACK_STRING image:[UIImage imageNamed:@"29-heart.png"] target:self selector:@selector(feedbackButtonPressed:)];
    OWDashboardItem *settings = [[OWDashboardItem alloc] initWithTitle:SETTINGS_STRING image:[UIImage imageNamed:@"19-gear.png"] target:self selector:@selector(settingsButtonPressed:)];
    
    OWBadgedDashboardItem *missions = [[OWBadgedDashboardItem alloc] initWithTitle:MISSIONS_STRING image:[UIImage imageNamed:@"108-badge.png"] target:self selector:@selector(missionsButtonPressed:)];
    NSArray *missionsArray = @[missions];
    
    NSArray *middleItems = @[topStories, local, rawFeed, yourMedia];
    NSArray *bottonItems = @[feedback, settings];
    NSArray *dashboardItems = @[missionsArray, middleItems, bottonItems];
    self.staticDashboardItems = dashboardItems;
    dashboardView.dashboardItems = dashboardItems;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.dashboardView = [[OWDashboardView alloc] initWithFrame:CGRectZero];

        [self setupStaticDashboardItems];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedAccountPermissionsErrorNotification:) name:kAccountPermissionsError object:nil];        
        [self prefetchNewMissions];
    }
    return self;
}

- (void) prefetchNewMissions {
    [[OWAccountAPIClient sharedClient] fetchMediaObjectsForFeedType:kOWFeedTypeMissions feedName:nil page:1 success:nil failure:nil];
}

- (void) receivedAccountPermissionsErrorNotification:(NSNotification*)notification {
    NSLog(@"%@ received", kAccountPermissionsError);
    [TestFlight passCheckpoint:kAccountPermissionsError];
    [OW_APP_DELEGATE.navigationController popToRootViewControllerAnimated:YES];
    OWLoginViewController *loginViewController = [[OWLoginViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    loginViewController.showCancelButton = NO;
    [self presentViewController:navController animated:YES completion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:WHOOPS_STRING message:SESSION_EXPIRED_STRING delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
        [alert show];
    }];
}


- (void) feedbackButtonPressed:(id)sender {
    UVConfig *config = [UVConfig configWithSite:@"openwatch.uservoice.com"
                                         andKey:USERVOICE_API_KEY
                                      andSecret:USERVOICE_API_SECRET];
    [UVStyleSheet setStyleSheet:[[OWStyleSheet alloc] init]];
    [UserVoice presentUserVoiceInterfaceForParentViewController:self andConfig:config];
}


- (void) feedButtonPressed:(id)sender {
    [self selectFeed:@"Top Stories" type:kOWFeedTypeFrontPage];
}

- (void) missionsButtonPressed:(id)sender {
    OWMissionListViewController *missionList = [[OWMissionListViewController alloc] init];
    [OW_APP_DELEGATE.navigationController setViewControllers:@[missionList] animated:NO];
    [self.revealController showViewController:self.revealController.frontViewController];
}

- (void) localFeedButtonPressed:(id)sender {
    [self selectFeed:@"Local" type:kOWFeedTypeFeed];
}

- (void) yourMediaPressed:(id)sender {
    OWLocalMediaObjectListViewController *recordingListVC = [[OWLocalMediaObjectListViewController alloc] init];
    [OW_APP_DELEGATE.navigationController setViewControllers:@[recordingListVC] animated:NO];
    [self.revealController showViewController:self.revealController.frontViewController];
}

- (void) selectFeed:(NSString*)feedName type:(OWFeedType)type {
    OWFeedViewController *feedVC = OW_APP_DELEGATE.feedViewController;
    [feedVC didSelectFeedWithName:feedName type:type];
    [OW_APP_DELEGATE.navigationController setViewControllers:@[feedVC] animated:NO];
    [self.revealController showViewController:self.revealController.frontViewController];
}

- (void) rawFeedPressed:(id)sender {
    [self selectFeed:@"Raw" type:kOWFeedTypeFeed];
}

- (void) settingsButtonPressed:(id) sender {
    OWSettingsViewController *settingsVC = [[OWSettingsViewController alloc] init];
    [OW_APP_DELEGATE.navigationController setViewControllers:@[settingsVC] animated:NO];
    [self.revealController showViewController:self.revealController.frontViewController];

}




- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:dashboardView];
    
    self.view.backgroundColor = [OWUtilities stoneBackgroundPattern];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat minWidth = 280.0f;
    CGFloat maxWidth = 310.0f;
    [self.revealController setMinimumWidth:minWidth maximumWidth:maxWidth forViewController:self];

    self.dashboardView.frame = CGRectMake(0, 0, minWidth, self.view.frame.size.height);
    
    [self refreshTagList];
}

- (void) locationUpdated:(CLLocation *)location {
    OWLocationController *locationController = [OWLocationController sharedInstance];
    [locationController stop];
    OWAccount *account = [OWSettingsController sharedInstance].account;
    if (account.secretAgentEnabled) {
        [[OWAccountAPIClient sharedClient] updateUserLocation:location];
    }
}

- (void) refreshTagList {
    [[OWAccountAPIClient sharedClient] getSubscribedTagsWithSuccessBlock:^(NSSet *tags) {
        NSMutableArray *newDashboardItems = [NSMutableArray arrayWithCapacity:tags.count];
        for (OWTag *tag in tags) {
            NSString *displayName = [NSString stringWithFormat:@"#%@", tag.name];
            OWTagDashboardItem *dashboardItem = [[OWTagDashboardItem alloc] initWithTitle:displayName image:nil target:self selector:@selector(didSelectTagWithName:)];
            dashboardItem.tag = tag;
            [newDashboardItems addObject:dashboardItem];
        }
        NSMutableArray *newDashboard = [NSMutableArray arrayWithArray:staticDashboardItems];
        [newDashboard addObject:newDashboardItems];
        self.dashboardView.dashboardItems = newDashboard;
    } failureBlock:nil];
}

- (void) didSelectTagWithName:(OWTagDashboardItem*)item {
    [self selectFeed:item.tag.name type:kOWFeedTypeTag];
}

@end
