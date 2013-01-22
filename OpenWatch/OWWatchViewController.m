//
//  OWWatchViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/11/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWWatchViewController.h"
#import "OWAccountAPIClient.h"
#import "OWTag.h"
#import "OWMediaObjectTableViewCell.h"
#import "OWStrings.h"
#import "OWUtilities.h"
#import "WEPopoverController.h"
#import "OWRecordingInfoViewController.h"
#import "OWStory.h"
#import "OWStoryViewController.h"
#import "OWMediaObjectViewController.h"
#import "MBProgressHUD.h"

@interface OWWatchViewController ()
@end

@implementation OWWatchViewController
@synthesize recordingsArray;
@synthesize feedSelector;
@synthesize feedType;
@synthesize selectedFeedString;

- (id)init
{
    self = [super init];
    if (self) {
        self.recordingsArray = [NSMutableArray array];
        self.title = WATCH_STRING;
        self.tableView.backgroundColor = [OWUtilities fabricBackgroundPattern];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(feedSelectionButtonPressed:)];
        self.feedSelector = [[OWFeedSelectionViewController alloc] init];
        feedSelector.delegate = self;
    }
    return self;
}

- (void) didSelectFeedWithName:(NSString *)feedName type:(OWFeedType)type shouldShowHUD:(BOOL)shouldShowHUD pageNumber:(NSUInteger)pageNumber {
    [TestFlight passCheckpoint:VIEW_FEED_CHECKPOINT(feedName)];
    selectedFeedString = feedName;
    feedType = type;
    self.title = feedName;
    if (shouldShowHUD) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    if (feedType == kOWFeedTypeFeed) {
        [[OWAccountAPIClient sharedClient] fetchRecordingsForFeed:feedName page:pageNumber success:^(NSArray *recordings) {
            [self reloadFeed:recordings];
        } failure:^(NSString *reason) {
            [self failedToLoadFeed:reason];
        }];
    } else if (feedType == kOWFeedTypeTag) {
        [[OWAccountAPIClient sharedClient] fetchRecordingsForTag:feedName page:pageNumber success:^(NSArray *recordings) {
            [self reloadFeed:recordings];
        } failure:^(NSString *reason) {
            [self failedToLoadFeed:reason];
        }];
    }

}

- (void) didSelectFeedWithName:(NSString *)feedName type:(OWFeedType)type {
    [self didSelectFeedWithName:feedName type:type shouldShowHUD:YES pageNumber:0];
}

- (void) reloadFeed:(NSArray*)recordings {
    self.recordingsArray = [NSMutableArray arrayWithArray:recordings];
    [self.tableView reloadData];
    
	[self doneLoadingTableViewData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) reloadTableViewDataSource {
    [super reloadTableViewDataSource];
    [self didSelectFeedWithName:selectedFeedString type:feedType shouldShowHUD:NO pageNumber:0];
}

- (void) failedToLoadFeed:(NSString*)reason {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return recordingsArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 147.0f;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MediaObjectCellIdentifier";
    OWMediaObjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[OWMediaObjectTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSManagedObjectID *recordingObjectID = [self.recordingsArray objectAtIndex:indexPath.row];
    cell.mediaObjectID = recordingObjectID;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObjectID *mediaObjectID = [self.recordingsArray objectAtIndex:indexPath.row];
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
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
