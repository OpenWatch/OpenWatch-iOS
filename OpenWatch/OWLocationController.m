//
//  OWLocationController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/21/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWLocationController.h"

@interface OWLocationControler()
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation OWLocationControler
@synthesize currentLocation, locationManager, delegate;

+ (OWLocationControler *)sharedInstance {
    static OWLocationControler *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
        _sharedClient = [[OWLocationControler alloc] init];
        });
    });
    return _sharedClient;
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

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    [self updateCurrentLocation:newLocation];
}

- (void) updateCurrentLocation:(CLLocation*)newLocation {
    if (!newLocation) {
        return;
    }
    if (!currentLocation) {
        [self.delegate startLocationUpdated:newLocation];
    }
    self.currentLocation = newLocation;
}

- (void) startWithDelegate:(id<OWLocationControlerDelegate>)newDelegate {
    self.delegate = newDelegate;
    [locationManager startUpdatingLocation];
}

- (void) stop {
    [locationManager stopUpdatingLocation];
    self.currentLocation = nil;
    self.delegate = nil;
}

@end
