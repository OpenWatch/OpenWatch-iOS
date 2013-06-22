//
//  OWMediaCreationController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMediaCreationController.h"
#import "OWPhoto.h"
#import "OWAppDelegate.h"
#import "OWAccountAPIClient.h"

@implementation OWMediaCreationController
@synthesize editController, presentingViewController;
@synthesize primaryTag;

- (void) captureViewController:(OWCaptureViewController *)captureViewController didFinishRecording:(OWLocalRecording *)recording {
    self.editController.objectID = recording.objectID;
    [captureViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) captureViewControllerDidCancel:(OWCaptureViewController *)captureViewController{
    [presentingViewController.navigationController popToRootViewControllerAnimated:NO];
}

- (void) recordVideoFromViewController:(UIViewController *)viewController {
    self.presentingViewController = viewController;
    OWCaptureViewController *captureVC = [[OWCaptureViewController alloc] init];
    captureVC.delegate = self;
    [presentingViewController presentViewController:captureVC animated:YES completion:^{
        [self pushEditView];
    }];
}

- (void) pushEditView {
    self.editController = [[OWLocalMediaEditViewController alloc] init];
    self.editController.primaryTag = self.primaryTag;
    self.editController.showingAfterCapture = YES;
    [presentingViewController.navigationController pushViewController:editController animated:YES];
}

@end
