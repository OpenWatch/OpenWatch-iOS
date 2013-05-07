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
#import "OWRecordingEditViewController.h"
#import "OWAppDelegate.h"
#import "OWUtilities.h"
#import "OWShareController.h"

@interface OWCaptureViewController ()
@end

@implementation OWCaptureViewController
@synthesize videoPreviewView, captureVideoPreviewLayer, videoProcessor, recordButton, photoButton;

- (id) init {
    if (self = [super init]) {
        self.videoProcessor = [OWCaptureController sharedInstance].videoProcessor;
        self.videoProcessor.delegate = self;
        [self.videoProcessor setupAndStartCaptureSession];
        self.videoPreviewView = [[UIView alloc] init];
        self.title = STREAMING_STRING;
        [self setupRecordButton];
    }
    return self;
}

- (void) setupRecordButton {
    self.recordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.recordButton.layer.opacity = 0.7;
    //recordButton.transform = CGAffineTransformMakeRotation(M_PI / 2);
    [recordButton setTitle:RECORD_STRING forState:UIControlStateNormal];
    self.recordButton.tintColor = [OWUtilities doneButtonColor];
    [self.recordButton addTarget:self action:@selector(recordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //self.recordButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
}

- (void) setupPhotoButton {
    self.photoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.recordButton.layer.opacity = 0.7;
    [recordButton setTitle:@"Take Photo" forState:UIControlStateNormal];
    [self.recordButton addTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}


- (void) photoButtonPressed:(id)sender {
    
}

- (void) loadView {
    [super loadView];
    self.videoPreviewView.frame = self.view.bounds;
    self.videoPreviewView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:videoPreviewView];
    [self.view addSubview:recordButton];
    [self.view addSubview:photoButton];
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
    self.recordButton.frame = CGRectMake(self.view.frame.size.width - buttonWidth - padding, padding, buttonWidth, buttonHeight);
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
		
		[UIApplication sharedApplication].idleTimerDisabled = NO;
                
		if ([[UIDevice currentDevice] isMultitaskingSupported]) {
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
			backgroundRecordingID = UIBackgroundTaskInvalid;
		}
        
        [self dismissViewControllerAnimated:YES completion:^{
            //[videoProcessor stopAndTearDownCaptureSession];
            OWRecordingEditViewController *recordingInfo = [[OWRecordingEditViewController alloc] init];
            recordingInfo.recordingID = videoProcessor.recordingID;
            recordingInfo.showingAfterCapture = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:recordingInfo];
            [OWUtilities styleNavigationController:nav];
            nav.navigationBar.tintColor = [OWUtilities navigationBarColor];
            [OW_APP_DELEGATE.dashboardViewController presentViewController:nav animated:YES completion:nil];
        }];
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
