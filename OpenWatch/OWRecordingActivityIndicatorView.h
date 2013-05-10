//
//  OWRecordingActivityIndicatorView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/9/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWRecordingActivityIndicatorView : UIView

@property (nonatomic, readonly) BOOL isAnimating;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSTimer *animationTimer;

- (void) startAnimating;
- (void) stopAnimating;

@end
