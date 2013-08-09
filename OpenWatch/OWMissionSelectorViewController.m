//
//  OWMissionSelectorViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 8/8/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMissionSelectorViewController.h"
#import "OWMission.h"
#import "OWAccountAPIClient.h"
#import "ODRefreshControl.h"

static NSString *cellIdentifier = @"CellIdentifier";

@interface OWMissionSelectorViewController ()

@end

@implementation OWMissionSelectorViewController
@synthesize missionsFRC, missionsTableView, callbackBlock, selectedMission;

- (id) initWithCallbackBlock:(OWMissionSelectionCallback)newCallbackBlock
{
    self = [super init];
    if (self) {
        self.callbackBlock = newCallbackBlock;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"expirationDate >= %@ && joined == YES", [NSDate date]];
        self.missionsFRC = [OWMission MR_fetchAllSortedBy:OWMediaObjectAttributes.title ascending:YES withPredicate:predicate groupBy:nil delegate:self];
        self.missionsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        self.missionsTableView.delegate = self;
        self.missionsTableView.dataSource = self;
        [self.missionsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.missionsTableView];
        [refreshControl addTarget:self action:@selector(refreshMissions:) forControlEvents:UIControlEventValueChanged];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(reset)];
    }
    return self;
}

- (void) reset {
    NSArray *missions = [OWMission MR_findAll];
    [missions enumerateObjectsUsingBlock:^(OWMission *mission, NSUInteger index, BOOL *stop) {
        NSLog(@"updating mission %@: %d", mission.title, mission.joinedValue);
        mission.joined = @YES;
        NSLog(@"updated mission %@: %d", mission.title, mission.joinedValue);
    }];
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            NSLog(@"error saving");
        }
    }];
}

- (void) doneButtonPressed:(id)sender {
    self.selectedMission.joined = @(!self.selectedMission.joinedValue);
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

- (void) refreshMissions:(ODRefreshControl*)refreshControl
{
    [[OWAccountAPIClient sharedClient] fetchMediaObjectsForFeedType:kOWFeedTypeMissions feedName:nil page:1 success:^(NSArray *mediaObjectIDs, NSUInteger totalPages) {
        NSLog(@"count: %d, totalPages: %d", mediaObjectIDs.count, totalPages);
        [refreshControl endRefreshing];
    } failure:^(NSString *reason) {
        NSLog(@"failed to fetch missions");
        [refreshControl endRefreshing];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view addSubview:missionsTableView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.missionsTableView.frame = self.view.bounds;
    /*
    [[OWAccountAPIClient sharedClient] fetchMediaObjectsForFeedType:kOWFeedTypeMissions feedName:nil page:1 success:^(NSArray *mediaObjectIDs, NSUInteger totalPages) {
        NSLog(@"count: %d, totalPages: %d", mediaObjectIDs.count, totalPages);
    } failure:^(NSString *reason) {
        NSLog(@"failed to fetch missions");
    }];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [[missionsFRC sections] count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[missionsFRC sections][section]numberOfObjects];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    OWMission *mission = [missionsFRC objectAtIndexPath:indexPath];
    cell.textLabel.text = mission.title;
    if (mission.joinedValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"will change content");
    [missionsTableView beginUpdates];
}

- (void) controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
        {
            [missionsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"insert section: %d", sectionIndex);
        }
            break;
        case NSFetchedResultsChangeUpdate:
        {
            [missionsTableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"update section: %d", sectionIndex);
        }
            break;
        case NSFetchedResultsChangeDelete:
        {
            [missionsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"delete section: %d", sectionIndex);
        }
            break;
        case NSFetchedResultsChangeMove:
        {
            NSLog(@"move section?? %d", sectionIndex);
        }
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
        {
            [missionsTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"insert row %@", newIndexPath);
        }
            break;
        case NSFetchedResultsChangeUpdate:
        {
            [missionsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"update row %@", indexPath);

        }
            break;
        case NSFetchedResultsChangeDelete:
        {
            [missionsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            NSLog(@"delete row %@", indexPath);

        }
            break;
        case NSFetchedResultsChangeMove:
        {
            [missionsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            if (newIndexPath) {
                [missionsTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            NSLog(@"move row from %@ to %@", indexPath, newIndexPath);
        }
            break;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedMission = [missionsFRC objectAtIndexPath:indexPath];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"did change content");
    [missionsTableView endUpdates];

}


@end
