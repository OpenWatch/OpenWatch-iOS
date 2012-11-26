//
//  OWRecordingInfoViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/26/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWRecordingInfoViewController.h"

@interface OWRecordingInfoViewController ()

@end

@implementation OWRecordingInfoViewController
@synthesize recording;

- (id) initWithRecording:(OWRecording *)newRecording {
    if (self = [super init]) {
        self.recording = newRecording;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
