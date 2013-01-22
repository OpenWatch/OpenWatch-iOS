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

@interface OWRecordingListViewController ()

@end

@implementation OWRecordingListViewController
@synthesize recordingsTableView, recordingController, recordingsArray, currentPage, totalPages;

- (id)init
{
    self = [super init];
    if (self) {
        self.recordingsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.recordingsTableView.dataSource = self;
        self.recordingsTableView.delegate = self;
        self.recordingController = [OWRecordingController sharedInstance];
        self.title = RECORDINGS_STRING;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
    }
    return self;
}

- (void) editButtonPressed:(id)sender {
    [self.recordingsTableView setEditing:!self.recordingsTableView.editing animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view addSubview:recordingsTableView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.recordingsTableView.frame = self.view.frame;
    [self refreshRecordings];
    [TestFlight passCheckpoint:VIEW_LOCAL_RECORDINGS];
    
    [[OWAccountAPIClient sharedClient] fetchUserRecordingsWithSuccessBlock:^{
        
    } failure:^(NSString *reason) {
        
    }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.recordingsTableView.frame = self.view.frame; // 
}

- (void) refreshRecordings {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.recordingController scanDirectoryForChanges];
        self.recordingsArray = [NSMutableArray arrayWithArray:[recordingController allRecordings]];
        [self.recordingsArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            OWLocalRecording *rec1 = [OWRecordingController recordingForObjectID:obj1];
            OWLocalRecording *rec2 = [OWRecordingController recordingForObjectID:obj2];
            return [rec1.startDate compare:rec2.startDate];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.recordingsTableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [recordingsArray count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MediaObjectCellIdentifier";
    OWMediaObjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[OWMediaObjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.isLocalRecording = YES;
    }
    NSManagedObjectID *recordingID = [recordingsArray objectAtIndex:indexPath.row];
    cell.mediaObjectID = recordingID;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 147.0f;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //OWLocalRecording *recording = [recordingsArray objectAtIndex:indexPath.row];
    // Return NO if you do not want the specified item to be editable.
    return YES;
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
        NSManagedObjectID *recordingID = [recordingsArray objectAtIndex:indexPath.row];
        OWLocalRecording *recording = [OWRecordingController recordingForObjectID:recordingID];
        // Delete the row from the data source
        [recordingsArray removeObjectAtIndex:indexPath.row];
        [recordingController removeRecording:recording.objectID];
        [recordingsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObjectID *recordingID = [recordingsArray objectAtIndex:indexPath.row];
    OWLocalRecording *recording = [OWRecordingController recordingForObjectID:recordingID];    if (![recording isKindOfClass:[OWLocalRecording class]]) {
        return;
    }
    OWRecordingEditViewController *recordingEditVC = [[OWRecordingEditViewController alloc] init];
    recordingEditVC.recordingID = recordingID;
    [self.navigationController pushViewController:recordingEditVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
