//
//  OWBadgedDashboardTableViewCell.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWDashboardTableViewCell.h"
#import "JSBadgeView.h"
#import "OWBadgedDashboardItem.h"

@interface OWBadgedDashboardTableViewCell : OWDashboardTableViewCell

@property (nonatomic, strong) OWBadgedDashboardItem *dashboardItem;

@end
