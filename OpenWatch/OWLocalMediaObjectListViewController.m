//
//  OWLocalMediaObjectListViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWLocalMediaObjectListViewController.h"
#import "OWLocalRecording.h"
#import "OWStrings.h"
#import "OWAccountAPIClient.h"
#import "OWMediaObjectTableViewCell.h"
#import "OWLocalMediaEditViewController.h"
#import "OWSettingsController.h"
#import "OWLocalRecordingTableViewCell.h"
#import "OWLocalMediaController.h"
#import "OWSettingsController.h"
#import "OWPhoto.h"

@interface OWLocalMediaObjectListViewController ()
@property (nonatomic) dispatch_queue_t queue;
@end

@implementation OWLocalMediaObjectListViewController
@synthesize objectIDSet, queue;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = RECORDINGS_STRING;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        self.objectIDSet = [NSMutableSet set];
        self.queue = dispatch_queue_create("Local Media Queue", 0);
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
    dispatch_async(queue, ^{
        [OWLocalMediaController scanDirectoryForChanges];
        OWSettingsController *settingsController = [OWSettingsController sharedInstance];
        NSMutableArray *objects = [NSMutableArray arrayWithArray:[OWLocalMediaController allMediaObjectsForUser:settingsController.account.user]];
        NSMutableArray *objectIDs = [NSMutableArray arrayWithCapacity:objects.count];
        for (NSManagedObject *object in objects) {
            [objectIDs addObject:object.objectID];
        }
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
        OWLocalMediaObject *object1 = [OWLocalMediaController localMediaObjectForObjectID:obj1];
        OWLocalMediaObject *object2 = [OWLocalMediaController localMediaObjectForObjectID:obj2];
        return [object1.firstPostedDate compare:object2.firstPostedDate];
    }];
}

- (void) didSelectFeedWithPageNumber:(NSUInteger)pageNumber {
    if (pageNumber <= kFirstPage) {
        self.currentPage = kFirstPage;
        [self loadOfflineRecordings];
    }
    
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
    NSManagedObjectID *objectID = [self.objectIDs objectAtIndex:indexPath.row];
    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:objectID];
    if ([mediaObject hasLocalData]) {
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
        OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:recordingID];
        // Delete the row from the data source
        [self.objectIDs removeObjectAtIndex:indexPath.row];
        [OWLocalMediaController removeLocalMediaObject:mediaObject.objectID];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= self.objectIDs.count) {
        return;
    }
    NSManagedObjectID *recordingID = [self.objectIDs objectAtIndex:indexPath.row];
    OWLocalMediaEditViewController *editVC = [[OWLocalMediaEditViewController alloc] init];
    editVC.objectID = recordingID;
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void) fetchObjectsForPageNumber:(NSUInteger)pageNumber {
    [self didSelectFeedWithPageNumber:pageNumber];
}

@end
