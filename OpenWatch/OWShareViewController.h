//
//  OWShareViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/14/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWMediaObject.h"
#import "BButton.h"
#import "OWPreviewView.h"
#import "OWLocalMediaObject.h"

@interface OWShareViewController : UIViewController

@property (nonatomic, strong) OWPreviewView *previewView;

@property (nonatomic, strong) OWLocalMediaObject *mediaObject;

@property (nonatomic, strong) BButton *shareButton;
@property (nonatomic, strong) UIBarButtonItem *skipButton;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *urlLabel;

@property (nonatomic) NSUInteger retryCount;

@end
