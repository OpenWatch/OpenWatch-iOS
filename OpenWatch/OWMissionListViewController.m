//
//  OWMissionListViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/28/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMissionListViewController.h"
#import "OWMission.h"
#import "OWMissionTableViewCell.h"
#import "OWMissionViewController.h"
#import "OWAccountAPIClient.h"
#import "OWStrings.h"
#import "OWSettingsController.h"
#import "OWUtilities.h"
#import "OWAppDelegate.h"
#import "PKRevealController.h"

@interface OWMissionListViewController ()

@end

@implementation OWMissionListViewController
@synthesize headerView;
@synthesize onboardingView;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = MISSIONS_STRING;
        
        [self.tableView registerClass:[OWMission cellClass] forCellReuseIdentifier:[OWMission cellIdentifier]];
        
        OWAccount *account = [OWSettingsController sharedInstance].account;
        if (!account.missionsDescriptionDismissed) {
            self.headerView = [[OWTooltipView alloc] initWithFrame:CGRectZero descriptionText:MISSIONS_DESCRIPTION_STRING icon:[UIImage imageNamed:@"108-badge.png"]];
            self.headerView.delegate = self;
        }
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self updateUserAccountInformation];
}

- (void) tooltipViewDidDismiss:(OWTooltipView *)tooltipView {
    self.headerView = nil;
    OWAccount *account = [OWSettingsController sharedInstance].account;
    account.missionsDescriptionDismissed = YES;
    [self.tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (headerView) {
        self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
        [OWUtilities applyShadowToView:headerView];
    }
    
    [self reloadTableViewDataSource];
    
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
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        [self.view addSubview:onboardingView];
    }
}

- (void) reloadTableViewDataSource {
    [super reloadTableViewDataSource];
    [self fetchObjectsForPageNumber:1];
}

- (void) didSelectFeedWithPageNumber:(NSUInteger)pageNumber {
    if (pageNumber <= kFirstPage) {
        self.currentPage = kFirstPage;
    }

    [[OWAccountAPIClient sharedClient] fetchMediaObjectsForFeedType:kOWFeedTypeMissions feedName:nil page:pageNumber success:^(NSArray *mediaObjectIDs, NSUInteger totalPages) {
        self.totalPages = totalPages;
        BOOL shouldReplaceObjects = NO;
        if (self.currentPage == kFirstPage) {
            shouldReplaceObjects = YES;
        }
        [self reloadFeed:mediaObjectIDs replaceObjects:shouldReplaceObjects];
        [self doneLoadingTableViewData];
    } failure:^(NSString *reason) {
        [self doneLoadingTableViewData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return headerView;
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return headerView.frame.size.height;
    }
    return 0;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= self.objectIDs.count) {
        return;
    }
    NSManagedObjectID *missionID = [self.objectIDs objectAtIndex:indexPath.row];
    OWMissionViewController *missionVC = [[OWMissionViewController alloc] init];
    missionVC.mediaObjectID = missionID;
    [self.navigationController pushViewController:missionVC animated:YES];
     
}

- (OWMediaObjectTableViewCell*) mediaObjectCellForIndexPath:(NSIndexPath *)indexPath {
    NSManagedObjectID *objectID = [self.objectIDs objectAtIndex:indexPath.row];
    OWMissionTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[OWMission cellIdentifier] forIndexPath:indexPath];
    cell.mediaObjectID = objectID;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.delegate = self;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.objectIDs.count) {
        return 45.0f;
    }
    NSManagedObjectID *objectID = [self.objectIDs objectAtIndex:indexPath.row];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context existingObjectWithID:objectID error:nil];
    return [OWMissionTableViewCell cellHeightForMediaObject:mediaObject];
}


- (void) fetchObjectsForPageNumber:(NSUInteger)pageNumber {
    [self didSelectFeedWithPageNumber:pageNumber];
}

- (void) onboardingViewDidComplete:(OWOnboardingView *)ow {
    [[Mixpanel sharedInstance] track:@"Onboarding Complete" properties:@{@"agent": @(onboardingView.agentSwitch.on)}];
    OW_APP_DELEGATE.revealController.recognizesPanningOnFrontView = YES;
    [self setupNavBar];
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

- (void) locationUpdated:(CLLocation *)location {
    OWLocationController *locationController = [OWLocationController sharedInstance];
    [locationController stop];
    OWAccount *account = [OWSettingsController sharedInstance].account;
    if (account.secretAgentEnabled) {
        [[OWAccountAPIClient sharedClient] updateUserLocation:location];
    }
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
