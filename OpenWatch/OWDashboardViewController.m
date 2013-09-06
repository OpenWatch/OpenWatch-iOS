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
#import "OWLocalMediaEditViewController.h"
#import "OWAppDelegate.h"
#import "OWSocialController.h"
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
#import "OWProfileDashboardItem.h"
#import "OWProfileViewController.h"

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
    OWDashboardItem *globalFeed = [[OWDashboardItem alloc] initWithTitle:GLOBAL_FEED_STRING image:[UIImage imageNamed:@"globe.png"] target:self selector:@selector(globalFeedPressed:)];
    OWDashboardItem *topVideos = [[OWDashboardItem alloc] initWithTitle:TOP_VIDEOS_STRING image:[UIImage imageNamed:@"280-clapboard.png"] target:self selector:@selector(topVideosPressed:)];
    
    OWDashboardItem *feedback = [[OWDashboardItem alloc] initWithTitle:SEND_FEEDBACK_STRING image:[UIImage imageNamed:@"29-heart.png"] target:self selector:@selector(feedbackButtonPressed:)];
    OWDashboardItem *settings = [[OWDashboardItem alloc] initWithTitle:SETTINGS_STRING image:[UIImage imageNamed:@"19-gear.png"] target:self selector:@selector(settingsButtonPressed:)];
    
    OWBadgedDashboardItem *missions = [[OWBadgedDashboardItem alloc] initWithTitle:MISSIONS_STRING image:[UIImage imageNamed:@"108-badge.png"] target:self selector:@selector(missionsButtonPressed:)];
    
    OWUser *user = [OWSettingsController sharedInstance].account.user;
    OWProfileDashboardItem *profileItem = [[OWProfileDashboardItem alloc] initWithUser:user target:self selector:@selector(profileButtonPressed:)];
    
    NSArray *middleItems = @[missions, topStories, topVideos, local, globalFeed, yourMedia];
    NSArray *topItems = @[profileItem, feedback, settings];
    NSArray *dashboardItems = @[topItems, middleItems];
    self.staticDashboardItems = dashboardItems;
    dashboardView.dashboardItems = dashboardItems;
}

- (void) profileButtonPressed:(id)sender {
    OWProfileViewController *profile = [[OWProfileViewController alloc] init];
    profile.user = [OWSettingsController sharedInstance].account.user;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:profile];
    [self presentViewController:nav animated:YES completion:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.dashboardView = [[OWDashboardView alloc] initWithFrame:CGRectZero];

        [self setupStaticDashboardItems];
        
        [self prefetchNewMissions];
    }
    return self;
}

- (void) prefetchNewMissions {
    [[OWAccountAPIClient sharedClient] fetchMediaObjectsForFeedType:kOWFeedTypeMissions feedName:nil page:1 success:nil failure:nil];
}

- (void) feedbackButtonPressed:(id)sender {
    UVConfig *config = [UVConfig configWithSite:@"openwatch.uservoice.com"
                                         andKey:USERVOICE_API_KEY
                                      andSecret:USERVOICE_API_SECRET];
    [UVStyleSheet setStyleSheet:[[OWStyleSheet alloc] init]];
    [UserVoice presentUserVoiceInterfaceForParentViewController:self andConfig:config];
}


- (void) feedButtonPressed:(id)sender {
    [self selectFeed:@"Top Stories" displayName:TOP_STORIES_STRING type:kOWFeedTypeFrontPage];
}

- (void) missionsButtonPressed:(id)sender {
    OWMissionListViewController *missionList = [[OWMissionListViewController alloc] init];
    [OW_APP_DELEGATE.navigationController setViewControllers:@[missionList] animated:NO];
    [self.revealController showViewController:self.revealController.frontViewController];
}

- (void) localFeedButtonPressed:(id)sender {
    [self selectFeed:@"local" displayName:LOCAL_FEED_STRING type:kOWFeedTypeFeed];
}

- (void) yourMediaPressed:(id)sender {
    OWLocalMediaObjectListViewController *recordingListVC = [[OWLocalMediaObjectListViewController alloc] init];
    [OW_APP_DELEGATE.navigationController setViewControllers:@[recordingListVC] animated:NO];
    [self.revealController showViewController:self.revealController.frontViewController];
}

- (void) selectFeed:(NSString*)feedName displayName:(NSString*)displayName type:(OWFeedType)type {
    OWFeedViewController *feedVC = OW_APP_DELEGATE.feedViewController;
    [feedVC didSelectFeedWithName:feedName displayName:displayName type:type];
    [OW_APP_DELEGATE.navigationController setViewControllers:@[feedVC] animated:NO];
    [self.revealController showViewController:self.revealController.frontViewController];
}

- (void) globalFeedPressed:(id)sender {
    [self selectFeed:@"raw" displayName:GLOBAL_FEED_STRING type:kOWFeedTypeFeed];
}

- (void) topVideosPressed:(id)sender {
    [self selectFeed:@"featured_media" displayName:TOP_VIDEOS_STRING type:kOWFeedTypeFeed];
}

- (void) settingsButtonPressed:(id) sender {
    OWSettingsViewController *settingsVC = [[[self settingsViewClass] alloc] init];
    [OW_APP_DELEGATE.navigationController setViewControllers:@[settingsVC] animated:NO];
    [self.revealController showViewController:self.revealController.frontViewController];

}

- (Class) settingsViewClass {
    return [OWSettingsViewController class];
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
    [self selectFeed:item.tag.name displayName:item.tag.name type:kOWFeedTypeTag];
}

@end
