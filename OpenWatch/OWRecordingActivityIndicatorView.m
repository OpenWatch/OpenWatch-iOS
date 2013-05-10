//
//  OWRecordingActivityIndicatorView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/9/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWRecordingActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationDuration 0.9f

@implementation OWRecordingActivityIndicatorView
@synthesize imageView, isAnimating, animationTimer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_dot.png"]];
        self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.layer.opacity = 0.0f;
        [self addSubview:imageView];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void) startAnimating {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(animationTimerFired:) userInfo:nil repeats:YES];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.imageView.layer.opacity = 1.0f;
    } completion:nil];
}

- (void) animationTimerFired:(NSTimer*)timer {
    CGFloat currentOpacity = self.imageView.layer.opacity;
    CGFloat newOpacity = 0.0f;
    if (currentOpacity > 0) {
        newOpacity = 0.0f;
    } else {
        newOpacity = 1.0f;
    }
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.imageView.layer.opacity = newOpacity;
    } completion:nil];
}

- (BOOL) isAnimating {
    if (self.animationTimer) {
        return YES;
    }
    return NO;
}

- (void) stopAnimating {
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.imageView.layer.opacity = 0.0f;
    } completion:nil];
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
