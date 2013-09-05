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
@synthesize videoPreviewView, captureVideoPreviewLayer, videoProcessor, fullscreenRecordButton, recordingIndicator, timerView, delegate, uploadStatusLabel, finishButton, startRecordingLabel;

- (id) init {
    if (self = [super init]) {
        self.videoProcessor = [OWCaptureController sharedInstance].videoProcessor;
        self.videoProcessor.delegate = self;
        [self.videoProcessor setupAndStartCaptureSession];
        self.videoPreviewView = [[UIView alloc] init];
        self.title = STREAMING_STRING;
        [self setupFinishButton];
        self.recordingIndicator = [[OWRecordingActivityIndicatorView alloc] init];
        self.timerView = [[OWTimerView alloc] init];
        self.uploadStatusLabel = [[UILabel alloc] init];
        [OWUtilities styleLabel:uploadStatusLabel];
        NSString *streaming = [NSString stringWithFormat:@"%@...", STREAMING_STRING];
        self.uploadStatusLabel.text = streaming;
        self.uploadStatusLabel.textAlignment = NSTextAlignmentRight;
        
        self.fullscreenRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [fullscreenRecordButton addTarget:self action:@selector(startRecordingPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self setupStartRecordingLabel];
    }
    return self;
}

- (void) setupStartRecordingLabel {
    self.startRecordingLabel = [[UILabel alloc] init];
    self.startRecordingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:30.0f];
    self.startRecordingLabel.numberOfLines = 0;
    self.startRecordingLabel.textColor = [UIColor whiteColor];
    self.startRecordingLabel.textAlignment = NSTextAlignmentCenter;
    self.startRecordingLabel.text = TOUCH_ANYWHERE_TO_START_STRING;
    self.startRecordingLabel.backgroundColor = [UIColor clearColor];
    self.startRecordingLabel.layer.shadowRadius = 2.5;
    self.startRecordingLabel.layer.masksToBounds = NO;
    self.startRecordingLabel.layer.shadowOpacity = 0.7;
    self.startRecordingLabel.layer.shouldRasterize = YES;
    self.startRecordingLabel.layer.shadowOffset = CGSizeMake(0, 0);
}

- (void) startRecordingPressed:(id)sender {
    [self.fullscreenRecordButton removeFromSuperview];
    [self.startRecordingLabel removeFromSuperview];
    [self.view addSubview:uploadStatusLabel];
    [videoProcessor startRecording];
    [self.finishButton setTitle:STOP_STRING forState:UIControlStateNormal];
    [[Mixpanel sharedInstance] track:@"Start Recording"];
}

- (void) setupFinishButton {
    self.finishButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeDanger];
    self.finishButton.layer.opacity = 0.7;
    [finishButton setTitle:CANCEL_STRING forState:UIControlStateNormal];
    [self.finishButton addTarget:self action:@selector(finishButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) loadView {
    [super loadView];
    self.videoPreviewView.frame = self.view.bounds;
    self.videoPreviewView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:videoPreviewView];
    [self.view addSubview:startRecordingLabel];
    [self.view addSubview:fullscreenRecordButton];
    [self.view addSubview:finishButton];
    [self.view addSubview:recordingIndicator];
    [self.view addSubview:timerView];
}

- (void) finishButtonPressed:(id)sender {
    if (![videoProcessor isRecording]) {
        [self.delegate captureViewControllerDidCancel:self];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STOP_RECORDING_STRING message:nil delegate:self cancelButtonTitle:NO_STRING otherButtonTitles:YES_STRING, nil];
        [alert show];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
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

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
	self.videoPreviewView.frame = self.view.bounds;
    CGFloat buttonWidth = 100.0f;
    CGFloat buttonHeight = 45.0f;
    CGFloat padding = 10.0f;
    CGFloat labelWidth = 100.0f;
    CGFloat labelHeight = 30.0f;
    
    CGFloat frameWidth = self.view.bounds.size.width;
    CGFloat frameHeight = self.view.bounds.size.height;
    
    self.uploadStatusLabel.frame = CGRectMake(frameWidth - labelWidth - padding, padding, labelWidth, labelHeight);
    self.recordingIndicator.frame = CGRectMake(padding, padding, 35, 35);
    self.finishButton.frame = CGRectMake(frameWidth - buttonWidth - padding, frameHeight - buttonHeight - padding, buttonWidth, buttonHeight);
    self.fullscreenRecordButton.frame = self.view.bounds;
    self.startRecordingLabel.frame = self.view.bounds;

    self.timerView.frame = CGRectMake([OWUtilities rightOfView:recordingIndicator], padding, 100, 35);
    [captureVideoPreviewLayer setFrame:self.view.bounds];
    [[Mixpanel sharedInstance] track:@"Showing Capture Screen"];
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
		[[self finishButton] setEnabled:NO];
		[[self finishButton] setTitle:STOP_STRING forState:UIControlStateNormal];
        
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
		[[self finishButton] setEnabled:YES];
        [self.timerView startTimer];
        [self.recordingIndicator startAnimating];
	});
}

- (void)recordingWillStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		// Disable until saving to the camera roll is complete
        [[OWLocationController sharedInstance] stop];
		[[self finishButton] setEnabled:NO];
	});
}

- (void)recordingDidStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
        [self.timerView stopTimer];
        [self.recordingIndicator stopAnimating];
		
		[UIApplication sharedApplication].idleTimerDisabled = NO;
                
		if ([[UIDevice currentDevice] isMultitaskingSupported]) {
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
			backgroundRecordingID = UIBackgroundTaskInvalid;
		}
        
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(captureViewController:didFinishRecording:)]) {
            OWLocalRecording *recording = (OWLocalRecording*)[OWLocalMediaController localMediaObjectForObjectID:videoProcessor.recordingID];
            [[Mixpanel sharedInstance] track:@"Finished Recording" properties:@{@"recording_uuid": recording.uuid}];
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
            [[self finishButton] setEnabled:NO];
            [videoProcessor stopRecording];
        }
    }
}


@end
