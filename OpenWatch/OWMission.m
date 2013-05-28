//
//  OWMission.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/28/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMission.h"


@implementation OWMission

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
