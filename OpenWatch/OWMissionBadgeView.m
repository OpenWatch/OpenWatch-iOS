//
//  OWMissionBadgeView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/21/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMissionBadgeView.h"

@implementation OWMissionBadgeView

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForNotifications];
    }
    return self;
}

- (void) updateBadgeText:(NSNotification*)notification {
    self.badgeText = [notification.userInfo objectForKey:[OWMissionBadgeView userInfoBadgeTextKey]];
}

+ (NSString*) userInfoBadgeTextKey {
    return @"badgeText";
}

- (void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeText:) name:kMissionCountUpdateNotification object:nil];
}

@end
