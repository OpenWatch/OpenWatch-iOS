//
//  OWWatchViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/11/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWWatchViewController.h"
#import "OWAccountAPIClient.h"
#import "OWRecordingTag.h"
#import "OWRemoteRecordingViewController.h"
#import "OWRecordingTableViewCell.h"
#import "OWStrings.h"
#import "OWUtilities.h"
#import "WEPopoverController.h"
#import "OWRecordingInfoViewController.h"

@interface OWWatchViewController ()
@end

@implementation OWWatchViewController
@synthesize recordingsTableView;
@synthesize recordingsArray;
@synthesize feedSelector;
@synthesize feedType;
@synthesize selectedFeedString;

- (id)init
{
    self = [super init];
    if (self) {
        self.recordingsTableView = [[UITableView alloc] init];
        self.recordingsTableView.delegate = self;
        self.recordingsTableView.dataSource = self;
        self.recordingsTableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        self.recordingsArray = [NSMutableArray array];
        self.title = WATCH_STRING;
        self.recordingsTableView.backgroundColor = [OWUtilities fabricBackgroundPattern];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(feedSelectionButtonPressed:)];
        self.feedSelector = [[OWFeedSelectionViewController alloc] init];
        feedSelector.delegate = self;
    }
    return self;
}

- (void) didSelectFeedWithName:(NSString *)feedName type:(OWFeedType)type {
    selectedFeedString = feedName;
    feedType = type;
    self.title = feedName;
    
    if (feedType == kOWFeedTypeFeed) {
        [[OWAccountAPIClient sharedClient] fetchRecordingsForFeed:feedName success:^(NSArray *recordings) {
            self.recordingsArray = [NSMutableArray arrayWithArray:recordings];
            [self.recordingsTableView reloadData];
        } failure:^(NSString *reason) {
            
        }];
    } else if (feedType == kOWFeedTypeTag) {
        [[OWAccountAPIClient sharedClient] fetchRecordingsForTag:feedName success:^(NSArray *recordings) {
            self.recordingsArray = [NSMutableArray arrayWithArray:recordings];
            [self.recordingsTableView reloadData];
        } failure:^(NSString *reason) {
            
        }];
    }
}

-(void)showPopOverListFor:(UIBarButtonItem*)buttonItem{
    [self.feedSelector presentPopoverFromBarButtonItem:buttonItem];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:recordingsTableView];
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
    self.recordingsTableView.frame = self.view.frame;

}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return recordingsArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 147.0f;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"RecordingCellIdentifier";
    OWRecordingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[OWRecordingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSManagedObjectID *recordingObjectID = [self.recordingsArray objectAtIndex:indexPath.row];
    cell.recordingObjectID = recordingObjectID;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObjectID *recordingObjectID = [self.recordingsArray objectAtIndex:indexPath.row];
    OWRecordingInfoViewController *recordingVC = [[OWRecordingInfoViewController alloc] init];
    recordingVC.isLocalRecording = NO;
    recordingVC.recordingID = recordingObjectID;
    [self.navigationController pushViewController:recordingVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
