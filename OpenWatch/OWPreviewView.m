//
//  OWPreviewView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/8/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWPreviewView.h"
#import "OWLocalMediaController.h"
#import "OWPhoto.h"
#import "OWLocalRecording.h"
#import "OWAudio.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@implementation OWPreviewView
@synthesize imageView, moviePlayer, objectID, isFullScreen, gestureRecognizer, previousFrame, isAnimating;

+ (CGFloat) heightForWidth:(CGFloat)width {
    return floorf(width * (3.0f/4.0f));
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateDidChangeNotification:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.moviePlayer stop];
    self.moviePlayer = nil;
}

- (void) moviePlayerLoadStateDidChangeNotification:(NSNotification*)notification {
    if (moviePlayer.loadState == MPMovieLoadStatePlayable) {
        [MBProgressHUD hideHUDForView:self animated:YES];
    }
}

- (void) setObjectID:(NSManagedObjectID *)newObjectID {
    objectID = newObjectID;
    
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    if (self.moviePlayer) {
        [self.moviePlayer.view removeFromSuperview];
        self.moviePlayer = nil;
    }
    
    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:objectID];
    NSURL *mediaURL = nil;
    if ([mediaObject isKindOfClass:[OWPhoto class]]) {
        isFullScreen = false;
        self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFullscreen)];
        [self addGestureRecognizer:gestureRecognizer];
        self.gestureRecognizer.delegate = self;
        OWPhoto *photo = (OWPhoto*)mediaObject;
        self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        if ([photo localImage]) {
            self.imageView.image = [photo localImage];
        } else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[photo remoteMediaURL]];
            [MBProgressHUD showHUDAddedTo:self.imageView animated:YES];
            __weak OWPreviewView* blockSelf = self;
            [self.imageView setImageWithURLRequest:request placeholderImage:[mediaObject placeholderThumbnailImage] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                blockSelf.imageView.image = image;

                [MBProgressHUD hideHUDForView:blockSelf.imageView animated:YES];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [MBProgressHUD hideHUDForView:blockSelf.imageView animated:YES];
            }];
        }

        [self addSubview:imageView];
    } else if ([mediaObject isKindOfClass:[OWLocalRecording class]]) {
        OWLocalRecording *recording = (OWLocalRecording*)mediaObject;
        mediaURL = recording.localMediaURL;
    } else if ([mediaObject isKindOfClass:[OWManagedRecording class]]) {
        OWManagedRecording *recording = (OWManagedRecording*)mediaObject;
        mediaURL = recording.remoteMediaURL;
    } else if ([mediaObject isKindOfClass:[OWAudio class]]) {
        OWAudio *audio = (OWAudio*)mediaObject;
        if (audio.localMediaPath.length > 0) {
            mediaURL = audio.localMediaURL;
        } else {
            mediaURL = audio.remoteMediaURL;
        }
    }
    if (mediaURL) {
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:mediaURL];
        self.moviePlayer.view.frame = self.frame;
        self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
        self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
        self.moviePlayer.shouldAutoplay = YES;
        self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
        [self.moviePlayer play];
        [self addSubview:moviePlayer.view];
    }
 }

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGRect bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if (self.imageView) {
        self.imageView.frame = bounds;
    }
    if (self.moviePlayer) {
        self.moviePlayer.view.frame = bounds;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)newGestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{
    BOOL shouldReceiveTouch = YES;
    
    if (newGestureRecognizer == gestureRecognizer) {
        shouldReceiveTouch = (touch.view == self.imageView);
    }
    
    return shouldReceiveTouch;
}

-(void)toggleFullscreen {
    if (self.isAnimating) {
        return;
    }
    self.isAnimating = YES;
    if (!self.isFullScreen) {
        self.isFullScreen = YES;
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            //save previous frame
            self.previousFrame = self.frame;
            CGRect newFrame = [UIScreen mainScreen].bounds;
            //newFrame.origin.y -= 37; // wtf???
            [self setFrame:newFrame];
        } completion:^(BOOL finished){
            self.isAnimating = NO;
        }];
    } else {
        isFullScreen = NO;
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            [self setFrame:self.previousFrame];
        } completion:^(BOOL finished){
            self.isAnimating = NO;
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
