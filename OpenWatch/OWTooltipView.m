//
//  OWMissionHeaderView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/8/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWTooltipView.h"
#import "OWStrings.h"
#import "OWSettingsController.h"

@implementation OWTooltipView
@synthesize descriptionLabel, closeButton;

- (id) initWithFrame:(CGRect)frame {
    if (self = [self initWithFrame:frame descriptionText:nil]) {
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame descriptionText:(NSString*)descriptionText {
    self = [super initWithFrame:frame];
    if (self) {
        self.descriptionLabel = [[UILabel alloc] init];
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.shadowColor = [UIColor whiteColor];
        self.descriptionLabel.shadowOffset = CGSizeMake(0, -1);
        self.descriptionLabel.numberOfLines = 0;
        self.descriptionLabel.text = descriptionText;
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ticks.png"]];
        
        [closeButton setImage:[UIImage imageNamed:@"UIBlackCloseButton.png"] forState:UIControlStateNormal];
        [closeButton setImage:[UIImage imageNamed:@"UIBlackCloseButtonPressed.png"] forState:UIControlStateHighlighted];
        
        [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:descriptionLabel];
        [self addSubview:closeButton];
        
        [self setFrame:frame];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGFloat closeButtonSize = 29;
    CGFloat padding = 10;
    CGFloat closeButtonPadding = 5;
    self.closeButton.frame = CGRectMake(frame
                                        .size.width - closeButtonSize - closeButtonPadding, closeButtonPadding, closeButtonSize, closeButtonSize);
    CGFloat xOffset = frame.size.width - closeButton.frame.origin.x + closeButtonPadding;
    self.descriptionLabel.frame = CGRectMake(padding, padding, frame.size.width - xOffset - padding, frame.size.height - padding * 2);
}



- (void) closeButtonPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tooltipViewWillDismiss:)]) {
        [self.delegate tooltipViewWillDismiss:self];
    }
    self.closeButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:1.0 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tooltipViewDidDismiss:)]) {
            [self.delegate tooltipViewDidDismiss:self];
        }
    }];

}

@end
