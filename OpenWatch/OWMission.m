//
//  OWMission.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/28/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMission.h"
#import "OWMissionTableViewCell.h"
#import "OWConstants.h"
#import "OWBadgedDashboardItem.h"

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

- (NSURL*) mediaURL {
    return [NSURL URLWithString:self.mediaURLString];
}

- (void) loadMetadataFromDictionary:(NSDictionary *)metadataDictionary {
    [super loadMetadataFromDictionary:metadataDictionary];
    NSNumber *active = [metadataDictionary objectForKey:@"active"];
    if (active) {
        self.active = active;
    }
    NSString *body = [metadataDictionary objectForKey:@"body"];
    if (body) {
        self.body = body;
    }
    NSNumber *completed = [metadataDictionary objectForKey:@"completed"];
    if (completed) {
        self.completed = completed;
    }
    NSNumber *karma = [metadataDictionary objectForKey:@"karma"];
    if (karma) {
        self.karma = karma;
    }
    NSString *mediaURLString = [metadataDictionary objectForKey:@"media_url"];
    if (mediaURLString) {
        self.mediaURLString = mediaURLString;
    }
    NSString *primaryTag = [metadataDictionary objectForKey:@"primary_tag"];
    if (primaryTag) {
        self.primaryTag = primaryTag;
    }
    NSNumber *usd = [metadataDictionary objectForKey:@"usd"];
    if (usd) {
        self.usd = usd;
    }
    
    NSNumber *latitude = [metadataDictionary objectForKey:@"end_lat"];
    if (latitude) {
        self.latitude = latitude;
    }
    NSNumber *longitude = [metadataDictionary objectForKey:@"end_lon"];
    if (longitude) {
        self.longitude = longitude;
    }
}

+ (void) updateUnreadCount {
    NSArray *unreadMissions = [OWMission MR_findByAttribute:OWMissionAttributes.viewed withValue:@(NO)];
    NSString *badgeText = @"";
    if (unreadMissions.count > 0) {
        badgeText = [NSString stringWithFormat:@"%d", unreadMissions.count];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kMissionCountUpdateNotification object:nil userInfo:@{[OWBadgedDashboardItem userInfoBadgeTextKey]: badgeText}];
}

- (CLLocationCoordinate2D) coordinate {
    return CLLocationCoordinate2DMake(self.latitudeValue, self.longitudeValue);
}

@end
