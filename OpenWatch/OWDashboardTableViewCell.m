//
//  OWDashboardTableViewCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/3/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWDashboardTableViewCell.h"
#import "OWUtilities.h"

@implementation OWDashboardTableViewCell
@synthesize dashboardItem;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.backgroundView = nil;
        self.imageView.contentMode = UIViewContentModeCenter;
    }
    return self;
}

- (void) setDashboardItem:(OWDashboardItem *)newDashboardItem {
    dashboardItem = newDashboardItem;
    
    self.imageView.image = dashboardItem.image;
    self.textLabel.text = dashboardItem.title;
}

@end
