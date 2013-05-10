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

@interface OWAudioRecordingViewController ()

@end

@implementation OWAudioRecordingViewController
@synthesize timeLabel, audioController, recorder, audio, recordButton, isRecording, cancelButton, microphoneImageView, recordingIndicatorView;

- (id)init
{
    self = [super init];
    if (self) {
        self.timeLabel = [[UILabel alloc] init];
        self.recordButton = [OWUtilities bigGreenButton];
        [recordButton setTitle:@"Start Recording" forState:UIControlStateNormal];
        [recordButton addTarget:self action:@selector(recordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.isRecording = NO;
        self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        self.microphoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"microphone.png"]];
        self.recordingIndicatorView = [[OWRecordingActivityIndicatorView alloc] init];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view addSubview:timeLabel];
    [self.view addSubview:recordButton];
    [self.view addSubview:recordingIndicatorView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.timeLabel.frame = CGRectMake(0, 0, 200, 50);
    CGFloat padding = 20.0f;
    self.recordButton.frame = CGRectMake(padding, padding, self.view.frame.size.width - padding*2, 100.0f);
    self.recordingIndicatorView.frame = CGRectMake(0, 0, 50, 50);
}

- (void) startNewRecording {
    self.audioController = [[AEAudioController alloc]
                            initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]
                            inputEnabled:YES];
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
}

- (void) finishRecording {
    [audioController removeInputReceiver:recorder];
    [audioController removeOutputReceiver:recorder];
    [self.recordingIndicatorView stopAnimating];
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
