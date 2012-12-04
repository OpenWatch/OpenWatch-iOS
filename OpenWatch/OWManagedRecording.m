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

@synthesize startLocation, endLocation;

- (CLLocation*) startLocation {
    if (startLocation) {
        return startLocation;
    }
    startLocation = [[CLLocation alloc] initWithLatitude:[self.startLatitude doubleValue] longitude:[self.startLongitude doubleValue]];
    return startLocation;
}

- (void) setStartLocation:(CLLocation *)newStartLocation {
    startLocation = newStartLocation;
    self.startLatitude = @(startLocation.coordinate.latitude);
    self.startLongitude = @(startLocation.coordinate.longitude);
}

- (CLLocation*) endLocation {
    if (endLocation) {
        return endLocation;
    }
    endLocation = [[CLLocation alloc] initWithLatitude:[self.endLatitude doubleValue] longitude:[self.endLongitude doubleValue]];
    return endLocation;
}

- (void) setEndLocation:(CLLocation *)newEndLocation {
    endLocation = newEndLocation;
    self.endLatitude = @(endLocation.coordinate.latitude);
    self.endLongitude = @(endLocation.coordinate.longitude);
}


@end
