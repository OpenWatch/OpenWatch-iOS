//
//  OWRecordingListViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWRecordingController.h"
#import "OWRecordingInfoViewController.h"
#import "OWPaginatedTableViewController.h"

@interface OWRecordingListViewController : OWPaginatedTableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableSet *objectIDSet;
@property (nonatomic, strong) OWRecordingController *recordingController;

@end
