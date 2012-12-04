//
//  OWLocationController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/21/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol OWLocationControlerDelegate <NSObject>
- (void) startLocationUpdated:(CLLocation*)location;
@end

@interface OWLocationController : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id<OWLocationControlerDelegate> delegate;
@property (nonatomic, strong) CLLocation *currentLocation;

- (void) startWithDelegate:(id<OWLocationControlerDelegate>)newDelegate;
- (void) stop;

+ (OWLocationController *)sharedInstance;

@end
