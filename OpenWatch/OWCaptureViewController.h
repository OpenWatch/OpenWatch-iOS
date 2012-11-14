//
//  OWCaptureViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWVideoProcessor.h"

@class AVCaptureVideoPreviewLayer;

@interface OWCaptureViewController : UIViewController

@property (nonatomic,retain) OWVideoProcessor *videoProcessor;
@property (nonatomic,retain) UIView *videoPreviewView;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@end
