//
//  OWKenBurnsView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 4/4/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWKenBurnsView.h"

@implementation OWKenBurnsView
@synthesize currentImageView, nextImageView, imageNames, currentImageIndex, imageCycleTimer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageNames = @[@"background1.jpg", @"background2.jpg"];
        self.currentImageIndex = 0;
        self.currentImageView = [[UIImageView alloc] initWithImage:[self currentImage]];
        self.currentImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.currentImageView.frame = self.bounds;
        [self addSubview:currentImageView];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.currentImageView.frame = frame;
}

- (UIImage*) currentImage {
    return [UIImage imageNamed:[imageNames objectAtIndex:currentImageIndex]];
}

- (UIImage*) nextImage {
    NSUInteger nextIndex = [self nextImageIndex];
    return [UIImage imageNamed:[imageNames objectAtIndex:nextIndex]];
}

- (NSUInteger) nextImageIndex {
    int nextIndex = self.currentImageIndex + 1;
    if (nextIndex >= imageNames.count) {
        nextIndex = 0;
    }
    return nextIndex;
}

- (void) startTimer {
    if (imageCycleTimer) {
        [imageCycleTimer invalidate];
    }
    self.imageCycleTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(cycleImage:) userInfo:nil repeats:YES];
}

- (void) zoomImageView:(UIImageView*)imageView {
    [UIView animateWithDuration:6.0f animations:^{
        imageView.transform = CGAffineTransformMakeScale(1.08,1.08);
    } completion:NULL];
}

- (void) cycleImage:(NSTimer*)timer {
    UIImage * newImage = [self nextImage];
    self.currentImageIndex = [self nextImageIndex];
    self.nextImageView = [[UIImageView alloc] initWithImage:newImage];
    self.nextImageView.alpha = 0.0f;
    [self addSubview:nextImageView];
    [self zoomImageView:nextImageView];
    
    
    [UIView animateWithDuration:1.0f animations:^{
        self.nextImageView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self.currentImageView removeFromSuperview];
        self.currentImageView = self.nextImageView;
    }];
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
