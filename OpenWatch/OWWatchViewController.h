//
//  OWWatchViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/11/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWRecordingListViewController.h"
#import "OWFeedSelectionViewController.h"

@interface OWWatchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, OWFeedSelectionDelegate>

@property (nonatomic, strong) UITableView *recordingsTableView;
@property (nonatomic, strong) NSMutableArray *recordingsArray;
@property (nonatomic, strong) OWFeedSelectionViewController *feedSelector;

@end
