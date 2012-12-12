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
        self.recordingsArray = [NSMutableArray array];
    }
    return self;
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

- (void) viewWillAppear:(BOOL)animated {
    self.recordingsTableView.frame = self.view.frame;
    [[OWAccountAPIClient sharedClient] fetchRecordingsForTag:@"police" success:^(NSArray *recordings) {
        self.recordingsArray = [NSMutableArray arrayWithArray:recordings];
        [self.recordingsTableView reloadData];
    } failure:^(NSString *reason) {
        
    }];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    OWManagedRecording *recording = [self.recordingsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [recording.dateModified description];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OWManagedRecording *recording = [self.recordingsArray objectAtIndex:indexPath.row];
    OWRemoteRecordingViewController *remoteVC = [[OWRemoteRecordingViewController alloc] init];
    remoteVC.recordingURL = [OWRecordingController detailPageURLForRecordingServerID:[recording.serverID intValue]];
    [self.navigationController pushViewController:remoteVC animated:YES];
}

@end
