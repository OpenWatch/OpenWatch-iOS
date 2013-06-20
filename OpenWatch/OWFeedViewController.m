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
#import "OWInvestigation.h"
#import "OWInvestigationViewController.h"
#import "OWStoryViewController.h"
#import "OWMediaObjectViewController.h"
#import "OWPhoto.h"
#import "OWAudio.h"
#import "PKRevealController.h"
#import "OWAppDelegate.h"

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
        [self setupNavBar];
        
        self.feedSelector = [[OWFeedSelectionViewController alloc] init];
        self.tableView.allowsSelection = NO;
        feedSelector.delegate = self;
    }
    return self;
}

- (void) setupNavBar {
    
    self.title = WATCH_STRING;
    UIImage *revealImagePortrait = [UIImage imageNamed:@"reveal_menu_icon_portrait"];
    UIImage *revealImageLandscape = [UIImage imageNamed:@"reveal_menu_icon_landscape"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:revealImagePortrait landscapeImagePhone:revealImageLandscape style:UIBarButtonItemStylePlain target:self action:@selector(showLeftView:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"285-facetime.png"] style:UIBarButtonItemStylePlain target:self action:@selector(startRecording:)];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openwatch.png"]];
    imageView.frame = CGRectMake(0, 0, 140, 25);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
}

- (void) startRecording:(id)sender {
    OW_APP_DELEGATE.creationController.primaryTag = nil;
    [OW_APP_DELEGATE.creationController recordVideoFromViewController:self];
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
    if (type == kOWFeedTypeTag) {
        self.title = [NSString stringWithFormat:@"#%@", feedName];
    } else {
        self.title = feedName;
    }
    
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
    if (self.feedType == kOWFeedTypeNone) {
        [self didSelectFeedWithName:nil type:kOWFeedTypeFrontPage];
    }
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
    OWMediaObject *mediaObject = (OWMediaObject*)[context existingObjectWithID:mediaObjectID error:nil];
    OWMediaObjectViewController *vc = nil;
    if ([mediaObject isKindOfClass:[OWManagedRecording class]]) {
        OWRecordingInfoViewController *recordingVC = [[OWRecordingInfoViewController alloc] init];
        vc = recordingVC;
    } else if ([mediaObject isKindOfClass:[OWStory class]]) {
        OWStoryViewController *storyVC = [[OWStoryViewController alloc] init];
        vc = storyVC;
    } else if ([mediaObject isKindOfClass:[OWInvestigation class]]) {
        OWInvestigationViewController *investigationVC = [[OWInvestigationViewController alloc] init];
        vc = investigationVC;
    } else if ([mediaObject isKindOfClass:[OWPhoto class]]) {
        OWRecordingInfoViewController *recordingVC = [[OWRecordingInfoViewController alloc] init];
        vc = recordingVC;
    } else if ([mediaObject isKindOfClass:[OWAudio class]]) {
        OWRecordingInfoViewController *recordingVC = [[OWRecordingInfoViewController alloc] init];
        vc = recordingVC;
    }
    if (vc) {
        vc.mediaObjectID = mediaObjectID;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) showLeftView:(id)sender {
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController) {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    } else {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}


@end
