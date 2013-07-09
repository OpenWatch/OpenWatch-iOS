//
//  OWEditableMediaCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/8/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWEditableMediaCell.h"
#import "OWUtilities.h"

@implementation OWEditableMediaCell
@synthesize textView, previewView;

+ (CGFloat) cellHeight {
    return 100.0f;
}

- (void) refreshFrames {
    CGFloat imageSize = 90.0f;
    CGFloat padding = 5.0f;
    
    self.textView.frame = CGRectMake(0, 0, self.contentView.frame.size.width - imageSize - padding * 2, [OWEditableMediaCell cellHeight]);
    self.previewView.frame = CGRectMake([OWUtilities rightOfView:textView], padding, imageSize, imageSize);
}

- (void) setTextView:(SSTextView *)newTextView {
    if (textView) {
        [textView removeFromSuperview];
    }
    textView = newTextView;
    [self.contentView addSubview:textView];
    [self refreshFrames];
}

- (void) setPreviewView:(OWPreviewView *)newPreviewView {
    if (previewView) {
        [previewView removeFromSuperview];
    }
    previewView = newPreviewView;
    previewView.moviePlayer.controlStyle = MPMovieControlStyleNone;
    [self.contentView addSubview:previewView];
    [self refreshFrames];
}

@end
