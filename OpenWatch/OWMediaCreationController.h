//
//  OWMediaCreationController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWCaptureViewController.h"
#import "OWLocationController.h"
#import "OWLocalMediaEditViewController.h"

@interface OWMediaCreationController : NSObject <OWCaptureDelegate>

@property (nonatomic, strong) UIViewController *presentingViewController;

@property (nonatomic, strong) OWLocalMediaEditViewController *editController;

- (void) recordVideoFromViewController:(UIViewController*)viewController;

@end
