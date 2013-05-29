//
//  OWBadgedDashboardItem.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWDashboardItem.h"
#import "JSBadgeView.h"

@interface OWBadgedDashboardItem : OWDashboardItem

@property (nonatomic, strong) JSBadgeView *badgeView;

// userInfo: badgeText to change badge text
- (void) registerForNotifications:(NSString*)notificationName;

+ (NSString*) userInfoBadgeTextKey;

@end
