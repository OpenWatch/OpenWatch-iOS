//
//  OWManagedRecording.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWManagedRecording.h"
#import "OWUtilities.h"
#import "OWTag.h"
#import "OWUser.h"


@interface OWManagedRecording()
@end

@implementation OWManagedRecording


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
    self.modifiedDate = [NSDate date];
    [super saveMetadata];
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

- (NSMutableDictionary*) metadataDictionary {
    NSMutableDictionary *newMetadataDictionary = [super metadataDictionary];
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
    if (self.modifiedDate) {
        [newMetadataDictionary setObject:[dateFormatter stringFromDate:self.modifiedDate] forKey:kLastEditedKey];
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

- (NSURL*) urlForWeb {
    NSString *baseURLString = [OWUtilities apiBaseURLString];
    NSString *recordingURLString = [baseURLString stringByAppendingFormat:@"v/%d/", [self.serverID intValue]];
    return [NSURL URLWithString:recordingURLString];
}

- (void) loadMetadataFromDictionary:(NSDictionary*)metadataDictionary {
    [super loadMetadataFromDictionary:metadataDictionary];
    NSDateFormatter *dateFormatter = [OWUtilities utcDateFormatter];
    
    NSString *videoURL = [metadataDictionary objectForKey:@"video_url"];
    if (videoURL) {
        self.remoteVideoURL = videoURL;
    }
    
    NSString *newUUID = [metadataDictionary objectForKey:kUUIDKey];
    if (newUUID) {
        self.uuid = newUUID;
    } else {
        NSLog(@"uuid not found!");
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
    NSString *thumbnailURL = [metadataDictionary objectForKey:@"thumbnail_url"];
    if (thumbnailURL)
    self.thumbnailURL = thumbnailURL;
}

- (CLLocation*)locationFromLocationDictionary:(NSDictionary*)locationDictionary {
    CLLocationDegrees latitude = [[locationDictionary objectForKey:kLatitudeKey] doubleValue];
    CLLocationDegrees longitude = [[locationDictionary objectForKey:kLongitudeKey] doubleValue];
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

- (NSString*) type {
    return @"video";
}


@end
