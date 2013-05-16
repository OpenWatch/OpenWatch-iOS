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

@implementation OWPreviewView
@synthesize imageView, moviePlayer, objectID;

+ (CGFloat) heightForWidth:(CGFloat)width {
    return floorf(width * (3.0f/4.0f));
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
    }
    return self;
}

- (void) dealloc {
    self.moviePlayer = nil;
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
        OWPhoto *photo = (OWPhoto*)mediaObject;
        self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
        self.imageView.image = [photo localImage];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
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
        self.moviePlayer.shouldAutoplay = NO;
        [self.moviePlayer prepareToPlay];
        moviePlayer.backgroundView.backgroundColor = [UIColor clearColor];
        moviePlayer.view.backgroundColor = [UIColor clearColor];
        for(UIView *aSubView in moviePlayer.view.subviews) {
            aSubView.backgroundColor = [UIColor clearColor];
        }
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
