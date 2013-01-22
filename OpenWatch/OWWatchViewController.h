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
#import "OWPaginatedTableViewController.h"


@interface OWWatchViewController : OWPaginatedTableViewController <OWFeedSelectionDelegate>

@property (nonatomic, strong) NSMutableArray *recordingsArray;
@property (nonatomic, strong) OWFeedSelectionViewController *feedSelector;

@end
