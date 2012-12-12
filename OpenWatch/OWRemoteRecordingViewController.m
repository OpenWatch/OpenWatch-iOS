//
//  OWRemoteRecordingViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/11/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWRemoteRecordingViewController.h"

@interface OWRemoteRecordingViewController ()

@end

@implementation OWRemoteRecordingViewController
@synthesize recordingWebView, recordingURL;

- (id)init
{
    self = [super init];
    if (self) {
        self.recordingWebView = [[UIWebView alloc] init];
        self.recordingWebView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:recordingWebView];
	// Do any additional setup after loading the view.
}

- (void) setRecordingURL:(NSURL *)newRecordingURL {
    recordingURL = newRecordingURL;
    NSURLRequest *request = [NSURLRequest requestWithURL:recordingURL];
    [recordingWebView loadRequest:request];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    recordingWebView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
