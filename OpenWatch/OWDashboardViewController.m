//
//  OWDashboardViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWDashboardViewController.h"
#import "OWUtilities.h"
#import "OWShareController.h"
#import "OWCaptureViewController.h"
#import "OWAccountAPIClient.h"
#import "OWSettingsViewController.h"
#import "OWRecordingListViewController.h"
#import "OWStrings.h"
#import "OWFeedViewController.h"
#import "OWFeedSelectionViewController.h"
#import "OWInvestigationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "OWSettingsController.h"
#import "OWFeedViewController.h"

#define kActionBarHeight 70.0f


@interface OWDashboardViewController ()

@end

@implementation OWDashboardViewController
@synthesize actionBarView, onboardingView;

- (id)init
{
    self = [super init];
    if (self) {
        self.actionBarView = [[OWActionBarView alloc] init];
        self.actionBarView.delegate = self;
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Feed" style:UIBarButtonItemStyleBordered target:self action:@selector(feedButtonPressed:)];
    }
    return self;
}

- (void) feedButtonPressed:(id)sender {
    OWFeedViewController *feedVC = [[OWFeedViewController alloc] init];
    [self.navigationController pushViewController:feedVC animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //[self.view addSubview:actionBarView];
    //self.tableView.tableHeaderView = actionBarView;
    //[self.view addSubview:onboardingImageView];
    
    self.view.backgroundColor = [OWUtilities stoneBackgroundPattern];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openwatch.png"]];
    imageView.frame = CGRectMake(0, 0, 140, 25);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
    
    
    [[OWAccountAPIClient sharedClient] getSubscribedTags];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    CGFloat actionBarHeight = kActionBarHeight;
    self.actionBarView.frame = CGRectMake(0, 0, self.view.frame.size.width, actionBarHeight);
    
    [self fetchObjectsForPageNumber:1];
    
    OWAccount *account = [OWSettingsController sharedInstance].account;

    if (!account.hasCompletedOnboarding) {
        self.onboardingView = [[OWOnboardingView alloc] initWithFrame:self.view.bounds scrollViewYOffset:kActionBarHeight - 2];
        self.onboardingView.delegate = self;
        [self.view addSubview:onboardingView];
        
        // TODO: stop using UITableViewController. move to UIViewController with content view and table view in it
        onboardingView.layer.zPosition = 1000;
    }
}

- (void) actionBarView:(OWActionBarView *)actionBarView didSelectButtonAtIndex:(NSUInteger)buttonIndex {
    NSLog(@"ButtonIndex: %d", buttonIndex);
    if (buttonIndex == 0) { // video 
        [self recordButtonPressed:nil];
    } else if (buttonIndex == 1) { //camera
        
    } else if (buttonIndex == 2) { // mic
        
    }
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return actionBarView;
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return kActionBarHeight;
    }
    return [super tableView:tableView heightForHeaderInSection:section];
}

- (void) recordButtonPressed:(id)sender {
    OWCaptureViewController *captureVC = [[OWCaptureViewController alloc] init];
    [self presentViewController:captureVC animated:YES completion:^{
    }];
}


- (void) settingsButtonPressed:(id)sender {
    OWSettingsViewController *settingsView = [[OWSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsView animated:YES];
}



- (void) savedButtonPressed:(id)sender {
    OWRecordingListViewController *recordingListView = [[OWRecordingListViewController alloc] init];
    [self.navigationController pushViewController:recordingListView animated:YES];
}

- (void) watchButtonPressed:(id)sender {
    OWFeedType type = kOWFeedTypeFeed;
    NSString *feedString = FEATURED_STRING;
    [self pushFeedVCForFeedName:feedString type:type];
}

- (void) pushFeedVCForFeedName:(NSString*)feedName type:(OWFeedType)type {
    OWFeedViewController *feedVC = [[OWFeedViewController alloc] init];
    [feedVC didSelectFeedWithName:feedName type:type];
    [self.navigationController pushViewController:feedVC animated:YES];
}

- (void) localButtonPressed:(id)sender {
    OWFeedType type = kOWFeedTypeFeed;
    NSString *feedString = LOCAL_STRING;
    [self pushFeedVCForFeedName:feedString type:type];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[OWShareController sharedInstance] shareFromViewController:self];
    }
}

- (void) fetchObjectsForPageNumber:(NSUInteger)pageNumber {
    self.currentPage = pageNumber;
    [[OWAccountAPIClient sharedClient] fetchMediaObjectsForFeedType:kOWFeedTypeFrontPage feedName:nil page:self.currentPage success:^(NSArray *mediaObjectIDs, NSUInteger totalPages) {
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

- (void) reloadTableViewDataSource {
    [super reloadTableViewDataSource];
    [self fetchObjectsForPageNumber:1];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= self.objectIDs.count) {
        return;
    }
    NSManagedObjectID *mediaObjectID = [self.objectIDs objectAtIndex:indexPath.row];
    //NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    //OWMediaObject *mediaObject = (OWMediaObject*)[context existingObjectWithID:mediaObjectID error:nil];
    
    OWInvestigationViewController *owc = [[OWInvestigationViewController alloc] init];
    owc.mediaObjectID = mediaObjectID;
    
    [self.navigationController pushViewController:owc animated:YES];
}

- (void) onboardingViewDidComplete:(OWOnboardingView *)onboardingView {
    OWAccount *account = [OWSettingsController sharedInstance].account;
    account.hasCompletedOnboarding = YES;
    [UIView animateWithDuration:2.0 animations:^{
        self.onboardingView.layer.opacity = 0.0f;
    } completion:^(BOOL finished) {
        [self.onboardingView removeFromSuperview];
        self.onboardingView = nil;
    }];
}

@end
