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

@interface OWMissionListViewController ()

@end

@implementation OWMissionListViewController
@synthesize headerView;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = MISSIONS_STRING;
        
        [self.tableView registerClass:[OWMission cellClass] forCellReuseIdentifier:[OWMission cellIdentifier]];
        
        OWAccount *account = [OWSettingsController sharedInstance].account;
        if (!account.missionsDescriptionDismissed) {
            self.headerView = [[OWTooltipView alloc] initWithFrame:CGRectZero descriptionText:MISSIONS_DESCRIPTION_STRING];
            self.headerView.delegate = self;
        }
    }
    return self;
}


- (void) tooltipViewDidDismiss:(OWTooltipView *)tooltipView {
    self.headerView = nil;
    [self.tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (headerView) {
        self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
        [OWUtilities applyShadowToView:headerView];
    }
    
    [TestFlight passCheckpoint:@"Missions"];
    [self reloadTableViewDataSource];
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
    return cell;
}


- (void) fetchObjectsForPageNumber:(NSUInteger)pageNumber {
    [self didSelectFeedWithPageNumber:pageNumber];
}

@end
