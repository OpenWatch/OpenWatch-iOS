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

@implementation OWPreviewView
@synthesize imageView, moviePlayer, objectID;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
    }
    return self;
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
    
    if ([mediaObject isKindOfClass:[OWPhoto class]]) {
        OWPhoto *photo = (OWPhoto*)mediaObject;
        self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
        self.imageView.image = [photo localImage];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self addSubview:imageView];
    } else if ([mediaObject isKindOfClass:[OWLocalRecording class]]) {
        OWLocalRecording *recording = (OWLocalRecording*)mediaObject;
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:recording.localMediaURL];
        [self.moviePlayer prepareToPlay];
        self.moviePlayer.view.frame = self.frame;
        [self addSubview:moviePlayer.view];
    } else if ([mediaObject isKindOfClass:[OWManagedRecording class]]) {
        OWManagedRecording *recording = (OWManagedRecording*)mediaObject;
        self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:recording.remoteMediaURL];
        [self.moviePlayer prepareToPlay];
        self.moviePlayer.view.frame = self.frame;
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
