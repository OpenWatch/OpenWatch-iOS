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

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
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

- (void) refreshRecordings {
    NSString *tagName = @"police";
    [[OWAccountAPIClient sharedClient] fetchRecordingsForTag:tagName success:^{
        OWRecordingTag *tag = [OWRecordingTag MR_findFirstByAttribute:@"name" withValue:tagName];
        NSSet *recordingsForTag = tag.recordings;
        self.recordingsArray = [NSMutableArray arrayWithArray:[recordingsForTag allObjects]];
        [self.recordingsArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            OWLocalRecording *rec1 = (OWLocalRecording*)obj1;
            OWLocalRecording *rec2 = (OWLocalRecording*)obj2;
            return [rec1.dateModified compare:rec2.dateModified];
        }];        
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
