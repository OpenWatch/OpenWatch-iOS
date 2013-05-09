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

@interface OWAudioRecordingViewController ()

@end

@implementation OWAudioRecordingViewController
@synthesize timeLabel;

- (id)init
{
    self = [super init];
    if (self) {
        self.timeLabel = [[UILabel alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view addSubview:timeLabel];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.timeLabel.frame = CGRectMake(0, 0, 200, 50);
}

- (void) startNewRecording {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
