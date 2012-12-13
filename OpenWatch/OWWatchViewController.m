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

@interface OWWatchViewController ()
@end

@implementation OWWatchViewController
@synthesize recordingsTableView;
@synthesize recordingsArray;

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
    }
    return self;
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

- (void) viewWillAppear:(BOOL)animated {
    self.recordingsTableView.frame = self.view.frame;
    [[OWAccountAPIClient sharedClient] fetchRecordingsForTag:@"police" success:^(NSArray *recordings) {
        self.recordingsArray = [NSMutableArray arrayWithArray:recordings];
        [self.recordingsTableView reloadData];
    } failure:^(NSString *reason) {
        
    }];
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
    OWManagedRecording *recording = [OWRecordingController recordingForObjectID:recordingObjectID];
    OWRemoteRecordingViewController *remoteVC = [[OWRemoteRecordingViewController alloc] init];
    remoteVC.recordingURL = [OWRecordingController detailPageURLForRecordingServerID:[recording.serverID intValue]];
    [self.navigationController pushViewController:remoteVC animated:YES];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
