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

@interface OWRecordingActivityIndicatorView()
@property (nonatomic) BOOL isAnimating;
@end


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
        self.isAnimating = NO;
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void) startAnimating {
    [self scheduleTimer];
    self.isAnimating = YES;
}

- (void) scheduleTimer {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(animationTimerFired:) userInfo:nil repeats:NO];
}

- (void) animationTimerFired:(NSTimer*)timer {
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.imageView.layer.opacity = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.imageView.layer.opacity = 0.0f;
        } completion:^(BOOL finished) {
            if (isAnimating) {
                [self scheduleTimer];
            }
        }];
    }];
}

- (void) stopAnimating {
    self.isAnimating = NO;
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
