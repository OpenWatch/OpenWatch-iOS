//
//  OWMissionSelectorViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 8/8/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMissionSelectorViewController.h"
#import "OWMission.h"
#import "OWAccountAPIClient.h"
#import "ODRefreshControl.h"
#import "UIImageView+AFNetworking.h"
#import "OWUtilities.h"
#import "OWMissionSelectionCell.h"
#import "OWStrings.h"

static NSString *cellIdentifier = @"CellIdentifier";
static NSString *missionCellIdentifier = @"MissionCellIdentifier";


@interface OWMissionSelectorViewController ()

@end

@implementation OWMissionSelectorViewController
@synthesize missionsFRC, missionsTableView, callbackBlock, selectedMission;

- (id) initWithCallbackBlock:(OWMissionSelectionCallback)newCallbackBlock
{
    self = [super init];
    if (self) {
        self.callbackBlock = newCallbackBlock;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"expirationDate >= %@", [NSDate date]];
        self.missionsFRC = [OWMission MR_fetchAllSortedBy:OWMissionAttributes.joined ascending:NO withPredicate:predicate groupBy:nil delegate:self];
        self.missionsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        self.missionsTableView.delegate = self;
        self.missionsTableView.dataSource = self;
        [self.missionsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        [self.missionsTableView registerClass:[OWMissionSelectionCell class] forCellReuseIdentifier:missionCellIdentifier];
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.missionsTableView];
        [refreshControl addTarget:self action:@selector(refreshMissions:) forControlEvents:UIControlEventValueChanged];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        self.title = CHOOSE_MISSION_STRING;
    }
    return self;
}

- (void) cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) doneButtonPressed:(id)sender {
    callbackBlock(self.selectedMission, nil);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) refreshMissions:(ODRefreshControl*)refreshControl
{
    [[OWAccountAPIClient sharedClient] fetchMediaObjectsForFeedType:kOWFeedTypeMissions feedName:nil page:1 success:^(NSArray *mediaObjectIDs, NSUInteger totalPages) {
        [self finishRefreshMissions:refreshControl];
    } failure:^(NSString *reason) {
        [self finishRefreshMissions:refreshControl];
    }];
}

- (void) finishRefreshMissions:(ODRefreshControl*)refreshControl {
    [refreshControl endRefreshing];
    self.selectedMission = nil;
    [missionsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view addSubview:missionsTableView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.missionsTableView.frame = self.view.bounds;
    [[OWAccountAPIClient sharedClient] fetchMediaObjectsForFeedType:kOWFeedTypeMissions feedName:nil page:1 success:^(NSArray *mediaObjectIDs, NSUInteger totalPages) {
        NSLog(@"count: %d, totalPages: %d", mediaObjectIDs.count, totalPages);
    } failure:^(NSString *reason) {
        NSLog(@"failed to fetch missions");
    }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [missionsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return [[missionsFRC sections][0]numberOfObjects];
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 45.0f;
    } else if (indexPath.section == 1) {
        return 100.0f;
    }
    return 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"No Mission";
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:missionCellIdentifier forIndexPath:indexPath];
        NSIndexPath *fakePath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        OWMission *mission = [missionsFRC objectAtIndexPath:fakePath];
        OWMissionSelectionCell *missionCell = (OWMissionSelectionCell*)cell;
        missionCell.mission = mission;
    }
    return cell;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [missionsTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)_indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)_newIndexPath {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:_indexPath.row inSection:1];
    NSIndexPath * newIndexPath = [NSIndexPath indexPathForRow:_newIndexPath.row inSection:1];
    switch(type) {
        case NSFetchedResultsChangeInsert:
        {
            [missionsTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
            break;
        case NSFetchedResultsChangeUpdate:
        {
            [missionsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
            break;
        case NSFetchedResultsChangeDelete:
        {
            [missionsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
            break;
        case NSFetchedResultsChangeMove:
        {
            [missionsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [missionsTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
            break;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        self.selectedMission = [missionsFRC objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    } else {
        self.selectedMission = nil;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [missionsTableView endUpdates];
}


@end
