//
//  OWVideoPreview.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/17/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWVideoPreview.h"
#import "UIImageView+AFNetworking.h"

static NSString *const OWVideoPreviewPlayButtonPressedNotification = @"OWVideoPreviewPlayButtonPressedNotification";

@interface OWVideoPreview()
@end

@implementation OWVideoPreview
@synthesize playButton, thumbnailImageView, moviePlayer, video, loadingIndicator;

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
        self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        [self.playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.thumbnailImageView addSubview:loadingIndicator];
        
        [self addSubview:moviePlayer.view];
        [self addSubview:thumbnailImageView];
        [self addSubview:playButton];
        
        [self setFrame:frame];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playButtonPressedNotification:) name:OWVideoPreviewPlayButtonPressedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preparedToPlayNotification:) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:moviePlayer];
    }
    return self;
}

- (void) preparedToPlayNotification:(NSNotification*)notification {
    [self setView:thumbnailImageView visible:!self.moviePlayer.isPreparedToPlay animated:YES];
}

- (void) playButtonPressedNotification:(NSNotification*)notification {
    OWVideoPreview *preview = notification.object;
    BOOL shouldShowPlayButton = preview != self;
    
    if (shouldShowPlayButton) {
        [loadingIndicator stopAnimating];
        [self.moviePlayer stop];
    } else {
        [loadingIndicator startAnimating];
    }
    
    [self setView:playButton visible:shouldShowPlayButton animated:YES];
}

- (void) setView:(UIView*)view visible:(BOOL)visible animated:(BOOL)animated {
    CGFloat alpha = 0.0f;
    CGFloat duration = 0.0f;
    if (visible) {
        alpha = 1.0f;
        view.userInteractionEnabled = YES;
    }
    if (animated) {
        duration = 2.0f;
    }
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        view.alpha = alpha;
    } completion:^(BOOL finished) {
        if (finished && !visible) {
            view.userInteractionEnabled = NO;
        }
    }];
}

- (void) playButtonPressed:(id)sender {
    
    if (video.hasLocalData) {
        self.moviePlayer.contentURL = video.localMediaURL;
    } else {
        self.moviePlayer.contentURL = video.remoteMediaURL;
    }
    [self.moviePlayer play];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OWVideoPreviewPlayButtonPressedNotification object:self];
}

- (void) setVideo:(OWManagedRecording *)newVideo {
    video = newVideo;
    
    [self setView:playButton visible:YES animated:NO];
    [self setView:thumbnailImageView visible:YES animated:NO];
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
