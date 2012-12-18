//
//  OWManagedRecording.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWManagedRecording.h"
#import "OWUtilities.h"
#import "OWRecordingTag.h"
#import "OWUser.h"

#define kLastEditedKey @"last_edited"
#define kTagsKey @"tags"
#define kUserKey @"user"
#define kUsernameKey @"username"
#define kIDKey @"id"

@interface OWManagedRecording()
@property (nonatomic, retain) NSNumber * endLatitude;
@property (nonatomic, retain) NSNumber * endLongitude;
@property (nonatomic, retain) NSNumber * startLatitude;
@property (nonatomic, retain) NSNumber * startLongitude;
@end

@implementation OWManagedRecording

@dynamic endDate;
@dynamic endLatitude;
@dynamic endLongitude;
@dynamic recordingDescription;
@dynamic startDate;
@dynamic startLatitude;
@dynamic startLongitude;
@dynamic title;
@dynamic uuid;
@dynamic serverID;
@dynamic remoteVideoURL;
@dynamic tags;
@dynamic user;
@dynamic dateModified;
@dynamic thumbnailURL;
@dynamic upvotes;
@dynamic views;

- (CLLocation*) startLocation {
    return [self locationWithLatitude:[self.startLatitude doubleValue] longitude:[self.startLongitude doubleValue]];
}

- (CLLocation*) locationWithLatitude:(double)latitude longitude:(double)longitude {
    if (latitude == 0.0f && longitude == 0.0f) {
        return nil;
    }
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

- (void) setStartLocation:(CLLocation *)startLocation {
    if (!startLocation) {
        return;
    }
    self.startLatitude = @(startLocation.coordinate.latitude);
    self.startLongitude = @(startLocation.coordinate.longitude);
}

- (void) saveMetadata {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    self.dateModified = [NSDate date];
    [context MR_saveNestedContexts];
}

- (CLLocation*) endLocation {
    return [self locationWithLatitude:[self.endLatitude doubleValue] longitude:[self.endLongitude doubleValue]];
}

- (void) setEndLocation:(CLLocation *)endLocation {
    if (!endLocation) {
        return;
    }
    self.endLatitude = @(endLocation.coordinate.latitude);
    self.endLongitude = @(endLocation.coordinate.longitude);
}

- (NSDictionary*) metadataDictionary {
    NSMutableDictionary *newMetadataDictionary = [NSMutableDictionary dictionary];
    if (self.uuid) {
        [newMetadataDictionary setObject:[self.uuid copy] forKey:kUUIDKey];
    }
    NSDateFormatter *dateFormatter = [OWUtilities utcDateFormatter];
    if (self.startDate) {
        [newMetadataDictionary setObject:[dateFormatter stringFromDate:self.startDate] forKey:kRecordingStartDateKey];
    }
    if (self.endDate) {
        [newMetadataDictionary setObject:[dateFormatter stringFromDate:self.endDate] forKey:kRecordingEndDateKey];
    }
    if (self.dateModified) {
        [newMetadataDictionary setObject:[dateFormatter stringFromDate:self.dateModified] forKey:kLastEditedKey];
    }
    if (self.title) {
        [newMetadataDictionary setObject:[self.title copy] forKey:kTitleKey];
    }
    if (self.recordingDescription) {
        [newMetadataDictionary setObject:[self.recordingDescription copy] forKey:kDescriptionKey];
    }
    if ([self locationIsValid:self.startLocation]) {
        NSDictionary *startLocationDictionary = [self locationDictionaryForLocation:self.startLocation];
        [newMetadataDictionary setObject:startLocationDictionary forKey:kLocationStartKey];
    }
    if ([self locationIsValid:self.endLocation]) {
        NSDictionary *endLocationDictionary = [self locationDictionaryForLocation:self.endLocation];
        [newMetadataDictionary setObject:endLocationDictionary forKey:kLocationEndKey];
    }
    NSSet *tags = self.tags;
    NSMutableArray *tagsArray = [NSMutableArray arrayWithCapacity:tags.count];
    for (OWRecordingTag *tag in tags) {
        if ([tag.name isEqualToString:@""]) {
            continue;
        }
        [tagsArray addObject:tag.name];
    }
    [newMetadataDictionary setObject:tagsArray forKey:kTagsKey];
    
    return newMetadataDictionary;
}

- (BOOL) locationIsValid:(CLLocation*)location {
    if (location.coordinate.latitude == 0.0f && location.coordinate.longitude == 0.0f) {
        return NO;
    }
    return YES;
}

- (NSDictionary*) locationDictionaryForLocation:(CLLocation*)location {
    NSMutableDictionary *locationDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    [locationDictionary setObject:@(location.coordinate.latitude) forKey:kLatitudeKey];
    [locationDictionary setObject:@(location.coordinate.longitude) forKey:kLongitudeKey];
    return locationDictionary;
}

- (NSURL*) urlForRemoteRecording {
    NSString *baseURLString = [OWUtilities apiBaseURLString];
    NSString *recordingURLString = [baseURLString stringByAppendingFormat:@"v/%d/", [self.serverID intValue]];
    return [NSURL URLWithString:recordingURLString];
}

- (void) loadMetadataFromDictionary:(NSDictionary*)metadataDictionary {
    
    NSNumber *serverID = [metadataDictionary objectForKey:@"id"];
    if (serverID) {
        self.serverID = serverID;
    }
    NSDateFormatter *dateFormatter = [OWUtilities utcDateFormatter];
    NSString *lastEdited = [metadataDictionary objectForKey:kLastEditedKey];
    if (lastEdited) {
        self.dateModified = [dateFormatter dateFromString:lastEdited];
    }
    
    NSString *videoURL = [metadataDictionary objectForKey:@"video_url"];
    if (videoURL) {
        self.remoteVideoURL = videoURL;
    }
    
    NSString *newUUID = [metadataDictionary objectForKey:kUUIDKey];
    if (newUUID) {
        self.uuid = newUUID;
    }
    NSString *newTitle = [metadataDictionary objectForKey:kTitleKey];
    if (newTitle) {
        self.title = newTitle;
    }
    NSString *newDescription = [metadataDictionary objectForKey:kDescriptionKey];
    if (newDescription) {
        self.recordingDescription = newDescription;
    }
    NSString *startDateString = [metadataDictionary objectForKey:kRecordingStartDateKey];
    if (startDateString) {
        self.startDate = [dateFormatter dateFromString:startDateString];
    }
    NSString *endDateString = [metadataDictionary objectForKey:kRecordingEndDateKey];
    if (endDateString) {
        self.endDate = [dateFormatter dateFromString:endDateString];
    }
    NSDictionary *startLocationDictionary = [metadataDictionary objectForKey:kLocationStartKey];
    if (startLocationDictionary) {
        self.startLocation = [self locationFromLocationDictionary:startLocationDictionary];
    }
    NSDictionary *endLocationDictionary = [metadataDictionary objectForKey:kLocationEndKey];
    if (endLocationDictionary) {
        self.endLocation = [self locationFromLocationDictionary:endLocationDictionary];
    }
    NSArray *tagsArray = [metadataDictionary objectForKey:kTagsKey];
    if (tagsArray) {
        NSMutableSet *tags = [NSMutableSet set];
        for (NSString *component in tagsArray) {
            if ([component isEqualToString:@""]) {
                continue;
            }
            OWRecordingTag *tag = [OWRecordingTag MR_findFirstByAttribute:@"name" withValue:component];
            if (!tag) {
                tag = [OWRecordingTag MR_createEntity];
                tag.name = component;
            }
            [tags addObject:tag];
        }
        self.tags = tags;
    }
    NSDictionary *userDictionary = [metadataDictionary objectForKey:kUserKey];
    if (userDictionary) {
        NSNumber *userID = [userDictionary objectForKey:kIDKey];
        NSString *username = [userDictionary objectForKey:kUsernameKey];
        OWUser *user = [OWUser MR_findFirstByAttribute:@"serverID" withValue:userID];
        if (!user) {
            user = [OWUser MR_createEntity];
            user.serverID = userID;
        }
        user.username = username;
        self.user = user;
    }
    NSNumber *views = [metadataDictionary objectForKey:@"views"];
    self.views = views;
    NSNumber *upvotes = [metadataDictionary objectForKey:@"clicks"];
    self.upvotes = upvotes;
    
    self.thumbnailURL = [metadataDictionary objectForKey:@"thumbnail_url"];
}

- (CLLocation*)locationFromLocationDictionary:(NSDictionary*)locationDictionary {
    CLLocationDegrees latitude = [[locationDictionary objectForKey:kLatitudeKey] doubleValue];
    CLLocationDegrees longitude = [[locationDictionary objectForKey:kLongitudeKey] doubleValue];
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}


@end
