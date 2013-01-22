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

@interface OWRecordingListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *recordingsTableView;
@property (nonatomic, strong) NSMutableArray *recordingsArray;
@property (nonatomic, strong) OWRecordingController *recordingController;

@end
