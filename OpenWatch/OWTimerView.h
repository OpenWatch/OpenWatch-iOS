//
//  OWTimerView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/9/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWTimerView : UIView

@property (nonatomic, readonly) BOOL isAnimating;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, strong) UILabel *timeLabel;

- (void) startTimer;
- (void) stopTimer;
- (void) resetTimer;

@end
