//
//  OWTimerView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/9/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWTimerView.h"

@implementation OWTimerView
@synthesize startDate, animationTimer, timeLabel;

- (void) dealloc {
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.timeLabel.text = @"00:00:00";
        [self addSubview:timeLabel];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.timeLabel.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

-(void) updateLabel:(UILabel*)label withTime:(NSTimeInterval)time
{
    int hour, minute, second;
	hour = time / 3600;
	minute = (time - hour * 3600) / 60;
	second = (time - hour * 3600 - minute * 60);
	label.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
}

- (void) animationTimerDidFire:(NSTimer*)timer {
    [self refreshLabel];
}

- (void) refreshLabel {
    NSTimeInterval secondsElapsed = [[NSDate date] timeIntervalSinceDate:startDate];
    [self updateLabel:timeLabel withTime:secondsElapsed];
}

- (BOOL) isAnimating {
    if (self.animationTimer) {
        return YES;
    }
    return NO;
}

- (void) startTimer {
    if (!self.startDate) {
        self.startDate = [NSDate date];
    }
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(animationTimerDidFire:) userInfo:nil repeats:YES];
}

- (void) stopTimer {
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

- (void) resetTimer {
    self.startDate = [NSDate date];
    [self refreshLabel];
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
