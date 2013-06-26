//
//  OWFeedViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/11/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWFeedViewController.h"
#import "OWAccountAPIClient.h"
#import "OWTag.h"
#import "OWStrings.h"
#import "OWUtilities.h"
#import "WEPopoverController.h"
#import "OWRecordingInfoViewController.h"
#import "OWStory.h"
#import "OWInvestigation.h"
#import "OWInvestigationViewController.h"
#import "OWStoryViewController.h"
#import "OWMediaObjectViewController.h"
#import "OWPhoto.h"
#import "OWAudio.h"
#import "PKRevealController.h"
#import "OWAppDelegate.h"
#import "OWSettingsController.h"

@interface OWFeedViewController ()
@end

@implementation OWFeedViewController
@synthesize feedType;
@synthesize selectedFeedString;
@synthesize lastLocation;
@synthesize onboardingView;

- (id)init
{
    self = [super init];
    if (self) {
        self.objectIDs = [NSMutableArray array];
    }
    return self;
}

- (void) locationUpdated:(CLLocation *)location {
    self.lastLocation = location;
    [[OWLocationController sharedInstance] stop];
    
    [self fetchObjectsForLocation:self.lastLocation page:self.currentPage];
}

- (void) fetchObjectsForLocation:(CLLocation*)location page:(NSUInteger)page {
    if (!location) {
        [[OWLocationController sharedInstance] startWithDelegate:self];
        return;
    }
    [[OWAccountAPIClient sharedClient] fetchMediaObjectsForLocation:location page:page success:^(NSArray *mediaObjectIDs, NSUInteger totalPages) {
        self.totalPages = totalPages;
        BOOL shouldReplaceObjects = NO;
        if (self.currentPage == kFirstPage) {
            shouldReplaceObjects = YES;
        }
        [self reloadFeed:mediaObjectIDs replaceObjects:shouldReplaceObjects];
    } failure:^(NSString *reason) {
        [self failedToLoadFeed:reason];
    }];
}

- (void) didSelectFeedWithName:(NSString *)feedName type:(OWFeedType)type pageNumber:(NSUInteger)pageNumber {
    if (pageNumber <= kFirstPage) {
        self.currentPage = kFirstPage;
        self.totalPages = 0;
        [super reloadTableViewDataSource];
        self.objectIDs = [NSMutableArray array];
        [self.tableView reloadData];
    }
    [TestFlight passCheckpoint:VIEW_FEED_CHECKPOINT(feedName)];
    selectedFeedString = feedName;
    feedType = type;
    if (type == kOWFeedTypeTag) {
        self.title = [NSString stringWithFormat:@"#%@", feedName];
    } else {
        self.title = feedName;
    }
    
    if ([[feedName lowercaseString] isEqualToString:@"local"]) {
        [self fetchObjectsForLocation:self.lastLocation page:pageNumber];
        return;
    }
    
    [[OWAccountAPIClient sharedClient] fetchMediaObjectsForFeedType:feedType feedName:feedName page:pageNumber success:^(NSArray *mediaObjectIDs, NSUInteger totalPages) {
        self.totalPages = totalPages;
        BOOL shouldReplaceObjects = NO;
        if (self.currentPage == kFirstPage) {
            shouldReplaceObjects = YES;
        }
        [self reloadFeed:mediaObjectIDs replaceObjects:shouldReplaceObjects];
        
    } failure:^(NSString *reason) {
        [self failedToLoadFeed:reason];
    }];
}

- (void) didSelectFeedWithName:(NSString *)feedName type:(OWFeedType)type {
    if ([feedName isEqualToString:self.selectedFeedString]) {
        return;
    }
    if (type == kOWFeedTypeFrontPage) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[self logoImage]];
        imageView.frame = CGRectMake(0, 0, 140, 25);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationItem.titleView = imageView;
    } else {
        self.title = feedName;
        self.navigationItem.titleView = nil;
    }
    [self didSelectFeedWithName:feedName type:type pageNumber:1];
}

- (void) fetchObjectsForPageNumber:(NSUInteger)pageNumber {
    [self didSelectFeedWithName:selectedFeedString type:feedType pageNumber:pageNumber];
}

- (void) reloadTableViewDataSource {
    [super reloadTableViewDataSource];
    [self didSelectFeedWithName:selectedFeedString type:feedType pageNumber:1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUserAccountInformation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) populateInitialFeed {
    if (self.feedType == kOWFeedTypeNone) {
        [self didSelectFeedWithName:nil type:kOWFeedTypeFrontPage];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TestFlight passCheckpoint:WATCH_CHECKPOINT];
    [self populateInitialFeed];
    
    CGFloat navigationBarHeightHack = 0.0f;
    
    if (self.navigationController.navigationBarHidden) {
        navigationBarHeightHack = self.navigationController.navigationBar.frame.size.height;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    OWAccount *account = [OWSettingsController sharedInstance].account;
    
    if (!account.hasCompletedOnboarding && !self.onboardingView) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeightHack);
        self.onboardingView = [[OWOnboardingView alloc] initWithFrame:frame];
        self.onboardingView.delegate = self;
        //self.onboardingView.frame = frame;
        [self.view addSubview:onboardingView];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[OWLocationController sharedInstance] stop];
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= self.objectIDs.count) {
        return;
    }
    NSManagedObjectID *mediaObjectID = [self.objectIDs objectAtIndex:indexPath.row];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context existingObjectWithID:mediaObjectID error:nil];
    OWMediaObjectViewController *vc = nil;
    if ([mediaObject isKindOfClass:[OWManagedRecording class]]) {
        return;
    } else if ([mediaObject isKindOfClass:[OWStory class]]) {
        OWStoryViewController *storyVC = [[OWStoryViewController alloc] init];
        vc = storyVC;
    } else if ([mediaObject isKindOfClass:[OWInvestigation class]]) {
        OWInvestigationViewController *investigationVC = [[OWInvestigationViewController alloc] init];
        vc = investigationVC;
    } else if ([mediaObject isKindOfClass:[OWPhoto class]]) {
        OWRecordingInfoViewController *recordingVC = [[OWRecordingInfoViewController alloc] init];
        vc = recordingVC;
    } else if ([mediaObject isKindOfClass:[OWAudio class]]) {
        OWRecordingInfoViewController *recordingVC = [[OWRecordingInfoViewController alloc] init];
        vc = recordingVC;
    }
    if (vc) {
        vc.mediaObjectID = mediaObjectID;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) tableCell:(OWMediaObjectTableViewCell *)cell didSelectHashtag:(NSString *)hashTag {
    [self didSelectFeedWithName:hashTag type:kOWFeedTypeTag];
}


- (void) onboardingViewDidComplete:(OWOnboardingView *)ow {
    OWAccount *account = [OWSettingsController sharedInstance].account;
    account.hasCompletedOnboarding = YES;
    account.secretAgentEnabled = onboardingView.agentSwitch.on;
    [self updateUserAccountInformation];
    [UIView animateWithDuration:2.0 animations:^{
        self.onboardingView.layer.opacity = 0.0f;
    } completion:^(BOOL finished) {
        [self.onboardingView removeFromSuperview];
        self.onboardingView = nil;
    }];
}

- (void) updateUserAccountInformation {
    OWAccount *account = [OWSettingsController sharedInstance].account;
    if (!account.isLoggedIn) {
        return;
    }
    [[OWAccountAPIClient sharedClient] updateUserSecretAgentStatus:account.secretAgentEnabled];
    if (!account.secretAgentEnabled) {
        return;
    }
    [[OWLocationController sharedInstance] startWithDelegate:self];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

@end
