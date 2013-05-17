//
//  OWPreviewView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/8/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface OWPreviewView : UIView <UIGestureRecognizerDelegate>

// Only used for OWPhoto type... should refactor this
@property (nonatomic, strong) UITapGestureRecognizer *gestureRecognizer;
@property (nonatomic) BOOL isFullScreen;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic) CGRect previousFrame;

- (void) toggleFullscreen;

+ (CGFloat) heightForWidth:(CGFloat)width;

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSManagedObjectID *objectID;

@end
