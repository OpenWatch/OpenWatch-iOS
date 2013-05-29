//
//  OWBadgedDashboardTableViewCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWBadgedDashboardTableViewCell.h"
#import "OWBadgedDashboardItem.h"
#import "JSBadgeView.h"

@implementation OWBadgedDashboardTableViewCell

- (void) setDashboardItem:(OWBadgedDashboardItem *)dashboardItem {
    [super setDashboardItem:dashboardItem];
    [self.contentView addSubview:dashboardItem.badgeView];
    self.dashboardItem.badgeView.frame = CGRectMake(260, 27, 20, 20);
    self.dashboardItem.badgeView.badgePositionAdjustment = CGPointMake(-30, 21);
}

@end
