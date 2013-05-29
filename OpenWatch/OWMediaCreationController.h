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
#import "OWAudioRecordingViewController.h"
#import "OWLocalMediaEditViewController.h"

@interface OWMediaCreationController : NSObject <OWAudioRecordingDelegate, OWCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIViewController *presentingViewController;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) OWAudioRecordingViewController *audioRecorder;
@property (nonatomic, strong) OWLocalMediaEditViewController *editController;

- (void) takePhotoFromViewController:(UIViewController*)viewController;
- (void) recordAudioFromViewController:(UIViewController*)viewController;
- (void) recordVideoFromViewController:(UIViewController*)viewController;

@end
