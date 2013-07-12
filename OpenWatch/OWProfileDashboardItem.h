//
//  OWProfileDashboardItem.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/11/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWDashboardItem.h"
#import "OWUser.h"

@interface OWProfileDashboardItem : OWDashboardItem

@property (nonatomic, strong) OWUser *user;

- (id) initWithUser:(OWUser*)newUser target:(id) newTarget selector:(SEL)newSelector;

@end
