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

@implementation OWLocalMediaObjectListViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = RECORDINGS_STRING;
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    
    [[OWAccountAPIClient sharedClient] fetchMediaObjectsForFeedType:kOWFeedTypeFeed feedName:@"user" page:pageNumber success:^(NSArray *mediaObjectIDs, NSUInteger totalPages) {
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
