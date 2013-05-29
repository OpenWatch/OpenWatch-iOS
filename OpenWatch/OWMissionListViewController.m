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

@interface OWMissionListViewController ()

@end

@implementation OWMissionListViewController



- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Missions";
        
        [self.tableView registerClass:[OWMission cellClass] forCellReuseIdentifier:[OWMission cellIdentifier]];

    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    NSArray *missions = [OWMission MR_findAll];
    NSMutableArray *objectIDs = [NSMutableArray arrayWithCapacity:missions.count];
    for (OWMission *mission in missions) {
        [objectIDs addObject:mission.objectID];
    }
    [self reloadFeed:objectIDs replaceObjects:YES];
    /*
    [[OWAccountAPIClient sharedClient] fetchMediaObjectsForFeedType:kOWFeedTypeFeed feedName:@"user" page:pageNumber success:^(NSArray *mediaObjectIDs, NSUInteger totalPages) {
        self.totalPages = totalPages;
        BOOL shouldReplaceObjects = NO;
        if (self.currentPage == kFirstPage) {
            shouldReplaceObjects = YES;
        }
        [self reloadFeed:mediaObjectIDs replaceObjects:shouldReplaceObjects];
        [self loadOfflineRecordings];
        [self doneLoadingTableViewData];
    } failure:^(NSString *reason) {
        [self loadOfflineRecordings];
        [self doneLoadingTableViewData];
    }];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= self.objectIDs.count) {
        return;
    }
    NSManagedObjectID *recordingID = [self.objectIDs objectAtIndex:indexPath.row];
    /*
    OWLocalMediaEditViewController *editVC = [[OWLocalMediaEditViewController alloc] init];
    editVC.objectID = recordingID;
    [self.navigationController pushViewController:editVC animated:YES];
     */
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
