//
//  OWDashboardTableViewCell.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/3/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWDashboardItem.h"

@interface OWDashboardTableViewCell : UITableViewCell

@property (nonatomic, strong) OWDashboardItem *dashboardItem;

@end
