//
//  OWWatchViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/11/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWRecordingListViewController.h"

@interface OWWatchViewController : UIViewController

@property (nonatomic, strong) UITableView *recordingsTableView;
@property (nonatomic, strong) NSMutableArray *recordingsArray;

@end
