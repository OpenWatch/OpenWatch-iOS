//
//  OWRecordingListViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWRecordingListViewController.h"
#import "OWLocalRecording.h"
#import "OWStrings.h"
#import "OWAccountAPIClient.h"
#import "OWMediaObjectTableViewCell.h"
#import "OWRecordingEditViewController.h"
#import "OWSettingsController.h"
#import "OWLocalRecordingTableViewCell.h"

@interface OWRecordingListViewController ()

@end

@implementation OWRecordingListViewController
@synthesize recordingController, objectIDSet;

- (id)init
{
    self = [super init];
    if (self) {
        self.recordingController = [OWRecordingController sharedInstance];
        self.title = RECORDINGS_STRING;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        self.objectIDSet = [NSMutableSet set];
        self.cellClass = [OWLocalRecordingTableViewCell class];
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TestFlight passCheckpoint:VIEW_LOCAL_RECORDINGS];
    [self reloadTableViewDataSource];
}

- (void) reloadTableViewDataSource {
    [super reloadTableViewDataSource];
    [self fetchObjectsForPageNumber:1];
}

- (void) loadOfflineRecordings {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.recordingController scanDirectoryForChanges];
        NSMutableArray *objectIDs = [NSMutableArray arrayWithArray:[recordingController allLocalRecordings]];
        [objectIDs addObjectsFromArray:self.objectIDs];
        [self.objectIDSet addObjectsFromArray:objectIDs];
        [self refreshRecordingsFromSet];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void) refreshRecordingsFromSet {
    self.objectIDs = [NSMutableArray arrayWithArray:[self.objectIDSet allObjects]];
    [self.objectIDs sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        OWManagedRecording *rec1 = [OWRecordingController recordingForObjectID:obj1];
        OWManagedRecording *rec2 = [OWRecordingController recordingForObjectID:obj2];
        return [rec2.startDate compare:rec1.startDate];
    }];
}

- (void) didSelectFeedWithPageNumber:(NSUInteger)pageNumber {
    if (pageNumber <= kFirstPage) {
        self.currentPage = kFirstPage;
        [self loadOfflineRecordings];
    }
    [[OWAccountAPIClient sharedClient] fetchUserRecordingsOnPage:pageNumber success:^(NSArray *recordingObjectIDs, NSUInteger totalPages) {
        self.totalPages = totalPages;
        BOOL shouldReplaceObjects = NO;
        if (self.currentPage == kFirstPage) {
            shouldReplaceObjects = YES;
        }
        [self reloadFeed:recordingObjectIDs replaceObjects:shouldReplaceObjects];
        [self loadOfflineRecordings];
        [self doneLoadingTableViewData];
    } failure:^(NSString *reason) {
        [self loadOfflineRecordings];
        [self doneLoadingTableViewData];
    }];
}

- (void) reloadFeed:(NSArray*)recordings replaceObjects:(BOOL)replaceObjects {
    [self.objectIDSet addObjectsFromArray:recordings];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.objectIDs.count) {
        return NO;
    }
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSManagedObjectID *recordingObjectID = [self.objectIDs objectAtIndex:indexPath.row];
    NSManagedObject *object = [context objectWithID:recordingObjectID];
    if ([object isKindOfClass:[OWLocalRecording class]]) {
        return YES;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectID *recordingID = [self.objectIDs objectAtIndex:indexPath.row];
        OWLocalRecording *recording = [OWRecordingController localRecordingForObjectID:recordingID];
        // Delete the row from the data source
        [self.objectIDs removeObjectAtIndex:indexPath.row];
        [recordingController removeRecording:recording.objectID];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= self.objectIDs.count) {
        return;
    }
    NSManagedObjectID *recordingID = [self.objectIDs objectAtIndex:indexPath.row];
    OWRecordingEditViewController *recordingEditVC = [[OWRecordingEditViewController alloc] init];
    recordingEditVC.recordingID = recordingID;
    [self.navigationController pushViewController:recordingEditVC animated:YES];
}

- (void) fetchObjectsForPageNumber:(NSUInteger)pageNumber {
    [self didSelectFeedWithPageNumber:pageNumber];
}

@end
