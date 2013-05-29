//
//  OWBadgedDashboardItem.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWBadgedDashboardItem.h"
#import "OWBadgedDashboardTableViewCell.h"

@implementation OWBadgedDashboardItem
@synthesize badgeView;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id) initWithTitle:(NSString *)newTitle image:(UIImage *)newImage target:(id)newTarget selector:(SEL)newSelector {
    if (self = [super initWithTitle:newTitle image:newImage target:newTarget selector:newSelector]) {
        self.badgeView = [[JSBadgeView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

+ (NSString*) cellIdentifier {
    return @"OWBadgedDashboardTableViewCell";
}

+ (Class) cellClass {
    return [OWBadgedDashboardTableViewCell class];
}

- (void) registerForNotifications:(NSString*)notificationName {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeText:) name:notificationName object:nil];
    
}

- (void) updateBadgeText:(NSNotification*)notification {
    self.badgeView.badgeText = [notification.userInfo objectForKey:[OWBadgedDashboardItem userInfoBadgeTextKey]];
}

+ (NSString*) userInfoBadgeTextKey {
    return @"badgeText";
}

@end
