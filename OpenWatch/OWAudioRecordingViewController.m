//
//  OWAudioRecordingViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/7/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWAudioRecordingViewController.h"
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "OWUtilities.h"
#import "OWAppDelegate.h"

@interface OWAudioRecordingViewController ()

@end

@implementation OWAudioRecordingViewController
@synthesize timerView, audioController, recorder, audio, recordButton, isRecording, cancelButton, microphoneImageView, recordingIndicatorView;

- (id)init
{
    self = [super init];
    if (self) {
        self.timerView = [[OWTimerView alloc] init];
        self.recordButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeDanger];
        [recordButton setTitle:@"Start Recording" forState:UIControlStateNormal];
        [recordButton addTarget:self action:@selector(recordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.isRecording = NO;
        self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        self.microphoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"microphone.png"]];
        self.microphoneImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.recordingIndicatorView = [[OWRecordingActivityIndicatorView alloc] init];
        self.title = @"Record Audio";
        self.audioController = OW_APP_DELEGATE.audioController;
    }
    return self;
}

- (void) cancelButtonPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingViewControllerDidCancel:)]) {
        [self.delegate recordingViewControllerDidCancel:self];
    }
}

- (void) recordButtonPressed:(id)sender {
    if (!self.isRecording) {
        [self startNewRecording];
        self.isRecording = YES;
        self.cancelButton.enabled = NO;
        [recordButton setTitle:@"Stop Recording" forState:UIControlStateNormal];
    } else {
        [self finishRecording];
        self.isRecording = NO;
        //self.cancelButton.enabled = YES;
        [recordButton setTitle:@"Start Recording" forState:UIControlStateNormal];
    }
}

- (void)loadView {
	UIView* view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	view.backgroundColor = [OWUtilities stoneBackgroundPattern];
	self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view addSubview:timerView];
    [self.view addSubview:recordButton];
    [self.view addSubview:recordingIndicatorView];
    [self.view addSubview:microphoneImageView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat padding = 20.0f;
    CGFloat microphoneSize = 200.0f;
    CGFloat width = self.view.frame.size.width;
    //CGFloat height = self.view.frame.size.height;
    CGFloat microphoneXOrigin = floorf(width/2 - microphoneSize/2);
    self.microphoneImageView.frame = CGRectMake(microphoneXOrigin, padding, microphoneSize, microphoneSize);

    CGFloat recordingYOrigin = [OWUtilities bottomOfView:microphoneImageView] + 10.0f;
    CGFloat indicatorHeight = 35.0f;
    
    self.recordingIndicatorView.frame = CGRectMake(microphoneXOrigin, recordingYOrigin, floorf(microphoneSize * .25), indicatorHeight);
    self.timerView.frame = CGRectMake([OWUtilities rightOfView:recordingIndicatorView], recordingYOrigin, floorf(microphoneSize * .75), indicatorHeight);
    
    self.recordButton.frame = CGRectMake(microphoneXOrigin, [OWUtilities bottomOfView:timerView] + 10.0f, microphoneSize, 50.0f);
}

- (void) startNewRecording {
    NSError *error = NULL;
    BOOL result = [audioController start:&error];
    if ( !result ) {
        NSLog(@"Error starting audio controller: %@", error.userInfo);
        error = nil;
        return;
    }
    
    self.audio = [OWAudio audio];
    
    // Init recorder
    self.recorder = [[AERecorder alloc] initWithAudioController:audioController];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:audio.dataDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"Error creating container directory: %@", error.userInfo);
        error = nil;
        return;
    }

    // Start the recording process
    error = NULL;
    if ( ![recorder beginRecordingToFileAtPath:audio.localMediaPath
                                       fileType:kAudioFileM4AType
                                          error:&error] ) {
        NSLog(@"Error starting recording: %@", error.userInfo);
        error = nil;
        return;
    }
    // Receive both audio input and audio output. Note that if you're using
    // AEPlaythroughChannel, mentioned above, you may not need to receive the input again.
    [audioController addInputReceiver:recorder];
    [audioController addOutputReceiver:recorder];
    [self.recordingIndicatorView startAnimating];
    [self.timerView startTimer];
}

- (void) finishRecording {
    [audioController removeInputReceiver:recorder];
    [audioController removeOutputReceiver:recorder];
    [self.recordingIndicatorView stopAnimating];
    [self.timerView stopTimer];
    [recorder finishRecording];
    self.recorder = nil;
    [audioController stop];
    self.audioController = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordingViewController:didFinishRecording:)]) {
        [self.delegate recordingViewController:self didFinishRecording:self.audio];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
