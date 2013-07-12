//
//  OWProfileDashboardCell.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/11/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWDashboardTableViewCell.h"
#import "OWUserView.h"

@interface OWProfileDashboardCell : OWDashboardTableViewCell

@property (nonatomic, strong) OWUserView *userView;

@end
