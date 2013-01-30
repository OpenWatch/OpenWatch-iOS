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
#import "OWStoryViewController.h"
#import "OWMediaObjectViewController.h"
#import "OWFeedTableViewCell.h"


@interface OWFeedViewController ()
@end

@implementation OWFeedViewController
@synthesize feedSelector;
@synthesize feedType;
@synthesize selectedFeedString;
@synthesize lastLocation;

- (id)init
{
    self = [super init];
    if (self) {
        self.objectIDs = [NSMutableArray array];
        self.title = WATCH_STRING;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(feedSelectionButtonPressed:)];
        self.feedSelector = [[OWFeedSelectionViewController alloc] init];
        feedSelector.delegate = self;
        self.cellClass = [OWFeedTableViewCell class];
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
        self.objectIDs = [NSArray array];
        [self.tableView reloadData];
    }
    [TestFlight passCheckpoint:VIEW_FEED_CHECKPOINT(feedName)];
    selectedFeedString = feedName;
    feedType = type;
    self.title = feedName;
    
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
    [self didSelectFeedWithName:feedName type:type pageNumber:1];
}

- (void) fetchObjectsForPageNumber:(NSUInteger)pageNumber {
    [self didSelectFeedWithName:selectedFeedString type:feedType pageNumber:pageNumber];
}

- (void) reloadTableViewDataSource {
    [super reloadTableViewDataSource];
    [self didSelectFeedWithName:selectedFeedString type:feedType pageNumber:1];
}

-(void)showPopOverListFor:(UIBarButtonItem*)buttonItem{
    [self.feedSelector presentPopoverFromBarButtonItem:buttonItem];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) feedSelectionButtonPressed:(id)sender {
    [self showPopOverListFor:self.navigationItem.rightBarButtonItem];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TestFlight passCheckpoint:WATCH_CHECKPOINT];
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
    OWMediaObject *mediaObject = (OWMediaObject*)[context objectWithID:mediaObjectID];
    OWMediaObjectViewController *vc = nil;
    if ([mediaObject isKindOfClass:[OWManagedRecording class]]) {
        OWRecordingInfoViewController *recordingVC = [[OWRecordingInfoViewController alloc] init];
        vc = recordingVC;
    } else if ([mediaObject isKindOfClass:[OWStory class]]) {
        OWStoryViewController *storyVC = [[OWStoryViewController alloc] init];
        vc = storyVC;
    }
    if (vc) {
        vc.mediaObjectID = mediaObjectID;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
