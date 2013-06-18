//
//  OWVideoPreview.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/17/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWVideoPreview.h"
#import "UIImageView+AFNetworking.h"

@implementation OWVideoPreview
@synthesize playButton, thumbnailImageView, moviePlayer, video, isPlayingVideo, loadingIndicator;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.moviePlayer stop];
    self.moviePlayer = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *playImage = [UIImage imageNamed:@"play-button.png"];
        [playButton setImage:playImage forState:UIControlStateNormal];
        //playButton.imageView.contentMode = UIViewContentModeCenter;
        
        self.thumbnailImageView = [[UIImageView alloc] init];
        self.moviePlayer = [[MPMoviePlayerController alloc] init];
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [self.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.thumbnailImageView addSubview:loadingIndicator];
        
        [self addSubview:moviePlayer.view];
        [self addSubview:thumbnailImageView];
        [self addSubview:playButton];
        
        [self setFrame:frame];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateDidChangeNotification:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];

    }
    return self;
}

- (void) playButtonPressed:(id)sender {
    if (isPlayingVideo) {
        return;
    }
    isPlayingVideo = YES;
    if (video.hasLocalData) {
        self.moviePlayer.contentURL = video.localMediaURL;
    } else {
        self.moviePlayer.contentURL = video.remoteMediaURL;
    }
    [self.moviePlayer prepareToPlay];
    
    [UIView animateWithDuration:2.0 animations:^{
        self.thumbnailImageView.alpha = 0.0f;
        self.playButton.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.thumbnailImageView removeFromSuperview];
        [self.playButton removeFromSuperview];
    }];
}

- (void) setVideo:(OWManagedRecording *)newVideo {
    video = newVideo;
    isPlayingVideo = NO;
    
    if (!thumbnailImageView.superview) {
        self.thumbnailImageView.alpha = 1.0f;
        [self addSubview:thumbnailImageView];
    }
    if (!playButton.superview) {
        self.playButton.alpha = 1.0f;
        [self addSubview:playButton];
    }
    [self.moviePlayer stop];
    
    UIImage *placeholderImage = [video placeholderThumbnailImage];    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:video.thumbnailURL];
    __weak OWVideoPreview *weakSelf = self;
    [loadingIndicator startAnimating];
    [self.thumbnailImageView setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.thumbnailImageView.image = image;
        [weakSelf.loadingIndicator stopAnimating];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakSelf.loadingIndicator stopAnimating];
        NSLog(@"Failed to load video preview thumbnail: %@", [error userInfo]);
    }];
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.moviePlayer.view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.thumbnailImageView.frame = self.moviePlayer.view.frame;
    self.loadingIndicator.frame = self.thumbnailImageView.frame;
    self.playButton.frame = self.thumbnailImageView.frame;
}

@end
