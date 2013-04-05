//
//  OWKenBurnsView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 4/4/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWKenBurnsView : UIView

@property (nonatomic, strong) UIImageView *currentImageView;
@property (nonatomic, strong) UIImageView *nextImageView;
@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic) NSUInteger currentImageIndex;
@property (nonatomic, strong) NSTimer *imageCycleTimer;

- (void) startTimer;
- (void) zoomImageView:(UIImageView*)imageView;

@end
