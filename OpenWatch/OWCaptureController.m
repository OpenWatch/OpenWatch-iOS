//
//  OWCaptureController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/29/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWCaptureController.h"

@implementation OWCaptureController
@synthesize videoProcessor;

+ (OWCaptureController *)sharedInstance {
    static OWCaptureController *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[OWCaptureController alloc] init];
    });
    return _sharedClient;
}

- (id) init {
    if (self = [super init]) {
        self.videoProcessor = [[OWVideoProcessor alloc] init];
        [self.videoProcessor setupAndStartCaptureSession];
    }
    return self;
}

@end
