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
#import "MBProgressHUD.h"
#import "OWAppDelegate.h"

@interface OWRecordingListViewController ()

@end

@implementation OWRecordingListViewController
@synthesize recordingController;

- (id)init
{
    self = [super init];
    if (self) {
        self.recordingController = [OWRecordingController sharedInstance];
        self.title = RECORDINGS_STRING;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
        [self.objectIDs sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            OWLocalRecording *rec1 = [OWRecordingController localRecordingForObjectID:obj1];
            OWLocalRecording *rec2 = [OWRecordingController localRecordingForObjectID:obj2];
            return [rec1.startDate compare:rec2.startDate];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadFeed:objectIDs replaceObjects:YES];
        });
    });
}

- (void) didSelectFeedWithPageNumber:(NSUInteger)pageNumber showHUD:(BOOL)shouldShowHUD {
    if (pageNumber <= kFirstPage) {
        self.currentPage = kFirstPage;
    }
    if (shouldShowHUD) {
        [MBProgressHUD showHUDAddedTo:OW_APP_DELEGATE.window animated:YES];
    }
    [[OWAccountAPIClient sharedClient] fetchUserRecordingsOnPage:pageNumber success:^(NSArray *recordingObjectIDs, NSUInteger totalPages) {
        self.totalPages = totalPages;
        BOOL shouldReplaceObjects = NO;
        if (self.currentPage == kFirstPage) {
            shouldReplaceObjects = YES;
        }
        [self reloadFeed:recordingObjectIDs replaceObjects:shouldReplaceObjects];
    } failure:^(NSString *reason) {
        [MBProgressHUD hideHUDForView:OW_APP_DELEGATE.window animated:YES];
        [self loadOfflineRecordings];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[OWMediaObjectTableViewCell class]]) {
        OWMediaObjectTableViewCell *mediaCell = (OWMediaObjectTableViewCell*)cell;
        mediaCell.isLocalRecording = YES;
    }
    return cell;
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
    [self didSelectFeedWithPageNumber:pageNumber showHUD:NO];;
}

@end
