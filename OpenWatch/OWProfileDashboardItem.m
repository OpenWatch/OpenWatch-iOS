//
//  OWProfileDashboardItem.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/11/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWProfileDashboardItem.h"
#import "OWProfileDashboardCell.h"

@implementation OWProfileDashboardItem
@synthesize user;

- (id) initWithUser:(OWUser *)newUser target:(id)newTarget selector:(SEL)newSelector {
    if (self = [super initWithTitle:nil image:nil target:newTarget selector:newSelector]) {
        self.user = newUser;
    }
    return self;
}

+ (NSString*) cellIdentifier {
    return @"OWProfileDashboardCell";
}

+ (Class) cellClass {
    return [OWProfileDashboardCell class];
}

@end
