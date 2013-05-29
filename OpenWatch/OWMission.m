//
//  OWMission.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/28/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMission.h"
#import "OWMissionTableViewCell.h"

@implementation OWMission

+ (Class) cellClass {
    return [OWMissionTableViewCell class];
}

- (NSString*) type {
    return @"mission";
}

- (UIImage*) placeholderThumbnailImage {
    return [UIImage imageNamed:@"image_placeholder.png"];
}

- (UIImage*) mediaTypeImage {
    return [UIImage imageNamed:@"108-badge.png"];
}

@end
