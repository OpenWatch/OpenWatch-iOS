//
//  OWCaptureViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWVideoProcessor.h"
#import "OWTimerView.h"
#import "OWRecordingActivityIndicatorView.h"
#import "BButton.h"

@class AVCaptureVideoPreviewLayer, OWCaptureViewController;

@protocol OWCaptureDelegate <NSObject>
@optional
- (void) captureViewController:(OWCaptureViewController*)captureViewController didFinishRecording:(OWLocalRecording*)recording;
- (void) captureViewControllerDidCancel:(OWCaptureViewController*)captureViewController;
@end

@interface OWCaptureViewController : UIViewController <OWVideoProcessorDelegate, UIAlertViewDelegate> {
    UIBackgroundTaskIdentifier backgroundRecordingID;
}

@property (nonatomic, weak) id<OWCaptureDelegate> delegate;
@property (nonatomic, strong) OWTimerView *timerView;
@property (nonatomic, strong) OWRecordingActivityIndicatorView *recordingIndicator;
@property (nonatomic, strong) UILabel *uploadStatusLabel;

@property (nonatomic, strong) BButton *recordButton;
@property (nonatomic, strong) OWVideoProcessor *videoProcessor;
@property (nonatomic, strong) UIView *videoPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@end
