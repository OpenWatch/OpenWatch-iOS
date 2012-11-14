//
//  OWCaptureViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWCaptureViewController.h"
#import "OWStrings.h"

@interface OWCaptureViewController ()

@end

@implementation OWCaptureViewController
@synthesize videoPreviewView, captureVideoPreviewLayer, videoProcessor;

- (id) init {
    if (self = [super init]) {
        self.videoProcessor = [[OWVideoProcessor alloc] init];
        [self.videoProcessor setupAndStartCaptureSession];
        self.videoPreviewView = [[UIView alloc] init];
        self.title = CAPTURE_STRING;
    }
    return self;
}

- (void) loadView {
    [super loadView];
    self.videoPreviewView.frame = self.view.bounds;
    self.videoPreviewView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:videoPreviewView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:videoProcessor.captureSession];
    
    UIView *view = [self videoPreviewView];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    if ([captureVideoPreviewLayer isOrientationSupported]) {
        [captureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [videoPreviewView.layer addSublayer:captureVideoPreviewLayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
