//
//  OWCaptureViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWCaptureViewController.h"
#import "OWStrings.h"
#import "OWCaptureController.h"
#import "OWLocalMediaEditViewController.h"
#import "OWAppDelegate.h"
#import "OWUtilities.h"
#import "OWLocalMediaController.h"

@interface OWCaptureViewController ()
@end

@implementation OWCaptureViewController
@synthesize videoPreviewView, captureVideoPreviewLayer, videoProcessor, recordButton, recordingIndicator, timerView, delegate, uploadStatusLabel;

- (id) init {
    if (self = [super init]) {
        self.videoProcessor = [OWCaptureController sharedInstance].videoProcessor;
        self.videoProcessor.delegate = self;
        [self.videoProcessor setupAndStartCaptureSession];
        self.videoPreviewView = [[UIView alloc] init];
        self.title = STREAMING_STRING;
        [self setupRecordButton];
        self.recordingIndicator = [[OWRecordingActivityIndicatorView alloc] init];
        self.timerView = [[OWTimerView alloc] init];
        self.uploadStatusLabel = [[UILabel alloc] init];
        [OWUtilities styleLabel:uploadStatusLabel];
        self.uploadStatusLabel.text = @"Streaming...";
        self.uploadStatusLabel.textAlignment = NSTextAlignmentRight;
    }
    return self;
}

- (void) setupRecordButton {
    self.recordButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeDanger];
    self.recordButton.layer.opacity = 0.7;
    //recordButton.transform = CGAffineTransformMakeRotation(M_PI / 2);
    [recordButton setTitle:RECORD_STRING forState:UIControlStateNormal];
    self.recordButton.tintColor = [OWUtilities doneButtonColor];
    [self.recordButton addTarget:self action:@selector(recordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //self.recordButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
}

- (void) loadView {
    [super loadView];
    self.videoPreviewView.frame = self.view.bounds;
    self.videoPreviewView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:videoPreviewView];
    [self.view addSubview:recordButton];
    [self.view addSubview:recordingIndicator];
    [self.view addSubview:timerView];
    [self.view addSubview:uploadStatusLabel];
}

- (void) recordButtonPressed:(id)sender {
    // Wait for the recording to start/stop before re-enabling the record button.
    if (![videoProcessor isRecording]) {
        [[self recordButton] setEnabled:NO];
        [videoProcessor startRecording];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STOP_RECORDING_STRING message:nil delegate:self cancelButtonTitle:NO_STRING otherButtonTitles:YES_STRING, nil];
        [alert show];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:videoProcessor.captureSession];
    self.captureVideoPreviewLayer.orientation = AVCaptureVideoOrientationLandscapeRight;
    
    UIView *view = [self videoPreviewView];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    /* iOS 6 doesn't like this
    if ([captureVideoPreviewLayer isOrientationSupported]) {
        [captureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationLandscapeRight];
    }
     */
    
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [videoPreviewView.layer addSublayer:captureVideoPreviewLayer];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.videoPreviewView.frame = self.view.bounds;
    CGFloat buttonWidth = 100.0f;
    CGFloat buttonHeight = 45.0f;
    CGFloat padding = 10.0f;
    CGFloat labelWidth = 100.0f;
    CGFloat labelHeight = 30.0f;
    
    // What's the deal with this iOS bug
    CGFloat frameWidth = self.view.frame.size.height;
    CGFloat frameHeight = self.view.frame.size.width;
    
    self.uploadStatusLabel.frame = CGRectMake(frameWidth - labelWidth - padding, padding, labelWidth, labelHeight);
    self.recordingIndicator.frame = CGRectMake(padding, padding, 35, 35);
    self.recordButton.frame = CGRectMake(frameWidth - buttonWidth - padding, frameHeight - buttonHeight - padding, buttonWidth, buttonHeight);

    self.timerView.frame = CGRectMake([OWUtilities rightOfView:recordingIndicator], padding, 100, 35);
    [captureVideoPreviewLayer setFrame:self.view.bounds];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self recordButtonPressed:nil];
    [TestFlight passCheckpoint:RECORDING_STARTED_CHECKPOINT];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark OWVideoProcessorDelegate

- (void)recordingWillStart
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self recordButton] setEnabled:NO];
		[[self recordButton] setTitle:STOP_STRING forState:UIControlStateNormal];
        
		// Disable the idle timer while we are recording
		[UIApplication sharedApplication].idleTimerDisabled = YES;
        
		// Make sure we have time to finish saving the movie if the app is backgrounded during recording
		if ([[UIDevice currentDevice] isMultitaskingSupported])
			backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
	});
}

- (void)recordingDidStart
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self recordButton] setEnabled:YES];
        [self.timerView startTimer];
        [self.recordingIndicator startAnimating];
	});
}

- (void)recordingWillStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		// Disable until saving to the camera roll is complete
        [[OWLocationController sharedInstance] stop];
		[[self recordButton] setTitle:RECORD_STRING forState:UIControlStateNormal];
		[[self recordButton] setEnabled:NO];
	});
}

- (void)recordingDidStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self recordButton] setEnabled:YES];
        [self.timerView stopTimer];
        [self.recordingIndicator stopAnimating];
		
		[UIApplication sharedApplication].idleTimerDisabled = NO;
                
		if ([[UIDevice currentDevice] isMultitaskingSupported]) {
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
			backgroundRecordingID = UIBackgroundTaskInvalid;
		}
        
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(captureViewController:didFinishRecording:)]) {
            OWLocalRecording *recording = (OWLocalRecording*)[OWLocalMediaController localMediaObjectForObjectID:videoProcessor.recordingID];
            [self.delegate captureViewController:self didFinishRecording:recording];
        }
	});
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationLandscapeRight == interfaceOrientation;
}

- (BOOL) shouldAutorotate {
    return NO;
}

-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

-(void)willAnimateRotationToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation
                                        duration:(NSTimeInterval)duration {
    
    [CATransaction begin];
    if (toInterfaceOrientation==UIInterfaceOrientationLandscapeRight){
        captureVideoPreviewLayer.orientation = AVCaptureVideoOrientationLandscapeRight;
    } else {
        captureVideoPreviewLayer.orientation = AVCaptureVideoOrientationLandscapeRight;
    }
    
    [CATransaction commit];
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if ( [videoProcessor isRecording] ) {
            [[self recordButton] setEnabled:NO];
            [videoProcessor stopRecording];
        }
    }
}


@end
