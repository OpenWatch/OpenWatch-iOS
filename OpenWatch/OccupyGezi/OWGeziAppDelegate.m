//
//  OWGeziAppDelegate.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/26/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWGeziAppDelegate.h"
#import "OWGeziLoginViewController.h"
#import "OWGeziDashboardViewController.h"
#import "OWGeziFeedViewController.h"

@implementation OWGeziAppDelegate

- (Class) loginControllerClass {
    return [OWGeziLoginViewController class];
}

- (Class) dashboardClass {
    return [OWGeziDashboardViewController class];
}

- (Class) feedViewClass {
    return [OWGeziFeedViewController class];
}

@end
