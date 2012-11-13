//
//  OWSettingsController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWSettingsController.h"

@implementation OWSettingsController
@synthesize account;

+ (OWSettingsController *)sharedInstance {
    static OWSettingsController *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OWSettingsController alloc] init];
    });
    return _sharedInstance;
}

- (id) init {
    if (self = [super init]) {
        self.account = [[OWAccount alloc] init];
    }
    return self;
}


@end
