//
//  OWRemoteRecordingViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/11/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWRemoteRecordingViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *recordingWebView;
@property (nonatomic, strong) NSURL *recordingURL;

@end
