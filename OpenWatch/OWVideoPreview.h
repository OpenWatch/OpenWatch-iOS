//
//  OWVideoPreview.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/17/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWManagedRecording.h"
#import <MediaPlayer/MediaPlayer.h>

@interface OWVideoPreview : UIView

@property (nonatomic) BOOL isPlayingVideo;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) OWManagedRecording *video;

@end
