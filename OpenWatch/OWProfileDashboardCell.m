//
//  OWProfileDashboardCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/11/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWProfileDashboardCell.h"
#import "UIImageView+AFNetworking.h"
#import "OWUtilities.h"
#import "OWProfileDashboardItem.h"

@implementation OWProfileDashboardCell
@synthesize userView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.userView = [[OWUserView alloc] initWithFrame:CGRectMake(2, 2, 250, 43)];
        [self.contentView addSubview:userView];
    }
    return self;
}

- (void) setDashboardItem:(OWProfileDashboardItem *)dashboardItem {
    [super setDashboardItem:dashboardItem];
    self.userView.user = dashboardItem.user;
}


@end
