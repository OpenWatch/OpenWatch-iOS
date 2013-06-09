//
//  OWMissionListViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/28/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWPaginatedTableViewController.h"
#import "OWTooltipView.h"

@interface OWMissionListViewController : OWPaginatedTableViewController <OWTooltipViewDelegate>

@property (nonatomic, strong) OWTooltipView *headerView;

@end
