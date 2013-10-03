//
//  OWAvamAppDelegate.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 10/2/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWAvamAppDelegate.h"
#import "OWAvamMissionListViewController.h"

@implementation OWAvamAppDelegate

- (Class) missionListClass {
    return [OWAvamMissionListViewController class];
}

- (void) setupFontManager {
    self.fontManager = [[OWFontManager alloc] initWithDefaultFontFamily:@"OpenSans"];
}

@end
