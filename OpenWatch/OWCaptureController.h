//
//  OWCaptureController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/29/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWVideoProcessor.h"

@interface OWCaptureController : NSObject

@property (nonatomic, strong) OWVideoProcessor *videoProcessor;

+ (OWCaptureController *)sharedInstance;

@end
