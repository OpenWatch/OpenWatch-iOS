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
#import "OWRecordingInfoViewController.h"
#import "OWAppDelegate.h"
#import "OWUtilities.h"

@interface OWCaptureViewController ()
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@end

@implementation OWCaptureViewController
@synthesize videoPreviewView, captureVideoPreviewLayer, videoProcessor, recordButton, cancelButton;

- (id) init {
    if (self = [super init]) {
        self.videoProcessor = [OWCaptureController sharedInstance].videoProcessor;
        self.videoProcessor.delegate = self;
        [self.videoProcessor setupAndStartCaptureSession];
        self.videoPreviewView = [[UIView alloc] init];
        self.title = CAPTURE_STRING;
        self.recordButton = [[UIBarButtonItem alloc] initWithTitle:RECORD_STRING style:UIBarButtonItemStyleDone target:self action:@selector(recordButtonPressed:)];
        self.recordButton.tintColor = [OWUtilities doneButtonColor];
        self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:CANCEL_STRING style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed:)];
    }
    return self;
}

- (void) loadView {
    [super loadView];
    self.videoPreviewView.frame = self.view.bounds;
    self.videoPreviewView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:videoPreviewView];
    
    self.navigationItem.rightBarButtonItem = recordButton;
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void) recordButtonPressed:(id)sender {
    // Wait for the recording to start/stop before re-enabling the record button.
    [[self recordButton] setEnabled:NO];
    self.cancelButton.enabled = NO;
    
    if ( [videoProcessor isRecording] ) {
        // The recordingWill/DidStop delegate methods will fire asynchronously in response to this call
        [videoProcessor stopRecording];
    }
    else {
        // The recordingWill/DidStart delegate methods will fire asynchronously in response to this call
        [videoProcessor startRecording];
    }
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
        [captureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationLandscapeRight];
    }
    
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [videoPreviewView.layer addSublayer:captureVideoPreviewLayer];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.videoPreviewView.frame = self.view.bounds;
    [captureVideoPreviewLayer setFrame:self.view.bounds];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self recordButtonPressed:nil];
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
		[[self recordButton] setTitle:STOP_STRING];
        
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
		[[self recordButton] setTitle:RECORD_STRING];
		[[self recordButton] setEnabled:NO];
	});
}

- (void)recordingDidStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self recordButton] setEnabled:YES];
        self.cancelButton.enabled = YES;
		
		[UIApplication sharedApplication].idleTimerDisabled = NO;
                
		if ([[UIDevice currentDevice] isMultitaskingSupported]) {
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
			backgroundRecordingID = UIBackgroundTaskInvalid;
		}
        
        [self dismissViewControllerAnimated:YES completion:^{
            //[videoProcessor stopAndTearDownCaptureSession];
            OWRecordingInfoViewController *recordingInfo = [[OWRecordingInfoViewController alloc] init];
            recordingInfo.isLocalRecording = YES;
            recordingInfo.recordingID = videoProcessor.recordingID;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:recordingInfo];
            nav.navigationBar.tintColor = [OWUtilities navigationBarColor];
            [OW_APP_DELEGATE.homeScreen presentViewController:nav animated:YES completion:nil];
        }];
	});
}

- (void) cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationLandscapeRight == interfaceOrientation;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}


@end
