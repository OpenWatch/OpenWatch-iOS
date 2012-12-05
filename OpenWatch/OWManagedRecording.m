//
//  OWManagedRecording.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWManagedRecording.h"

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
    [self saveMetadata];
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
    [self saveMetadata];
}


@end
