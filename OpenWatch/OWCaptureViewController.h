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

@class AVCaptureVideoPreviewLayer;

@interface OWCaptureViewController : UIViewController <OWVideoProcessorDelegate, UIAlertViewDelegate> {
    UIBackgroundTaskIdentifier backgroundRecordingID;
}

@property (nonatomic, strong) OWTimerView *timerView;
@property (nonatomic, strong) OWRecordingActivityIndicatorView *recordingIndicator;

@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) OWVideoProcessor *videoProcessor;
@property (nonatomic, strong) UIView *videoPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@end
