//
//  OWLocationController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/21/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWLocationController.h"
#import "OWAppDelegate.h"

@interface OWLocationController()
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation OWLocationController
@synthesize currentLocation, locationManager, delegate;

+ (OWLocationController *)sharedInstance {
    return OW_APP_DELEGATE.locationController;
}

- (id) init {
    if (self = [super init]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    return self;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self updateCurrentLocation:newLocation];
}

+ (BOOL) locationIsValid:(CLLocation*)location {
    if (location.coordinate.latitude == 0.0f && location.coordinate.longitude == 0.0f) {
        return NO;
    }
    return YES;
}


- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    [self updateCurrentLocation:newLocation];
}

- (void) updateCurrentLocation:(CLLocation*)newLocation {
    if (!newLocation) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationUpdated:)]) {
        [self.delegate locationUpdated:newLocation];
    }
    self.currentLocation = newLocation;
}

- (void) startWithDelegate:(id<OWLocationControllerDelegate>)newDelegate {
    self.delegate = newDelegate;
    if (fabs([[NSDate date] timeIntervalSinceDate:currentLocation.timestamp]) < 60) {
        self.currentLocation = nil;
    }
    if (self.currentLocation) {
        [self updateCurrentLocation:currentLocation];
    }
    [locationManager startUpdatingLocation];
}

- (void) stop {
    [locationManager stopUpdatingLocation];
    self.delegate = nil;
}

@end
