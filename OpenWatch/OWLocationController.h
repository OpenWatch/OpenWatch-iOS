//
//  OWLocationController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/21/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol OWLocationControllerDelegate <NSObject>
- (void) locationUpdated:(CLLocation*)location;
@end

@interface OWLocationController : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id<OWLocationControllerDelegate> delegate;
@property (atomic, strong) CLLocation *currentLocation;

- (void) startWithDelegate:(id<OWLocationControllerDelegate>)newDelegate;
- (void) stop;

+ (OWLocationController *)sharedInstance;

@end
