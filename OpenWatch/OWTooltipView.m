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
@synthesize descriptionLabel, closeButton, iconView;

- (id) initWithFrame:(CGRect)frame {
    if (self = [self initWithFrame:frame descriptionText:nil]) {
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame descriptionText:(NSString *)descriptionText {
    if (self = [self initWithFrame:frame descriptionText:descriptionText icon:nil]) {
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame descriptionText:(NSString*)descriptionText icon:(UIImage *)icon {
    self = [super initWithFrame:frame];
    if (self) {
        self.descriptionLabel = [[UILabel alloc] init];
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.font = [UIFont systemFontOfSize:18.0f];
        self.descriptionLabel.shadowColor = [UIColor whiteColor];
        self.descriptionLabel.shadowOffset = CGSizeMake(0, -1);
        self.descriptionLabel.numberOfLines = 0;
        self.descriptionLabel.text = descriptionText;
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ticks.png"]];
        
        [closeButton setImage:[UIImage imageNamed:@"UIBlackCloseButton.png"] forState:UIControlStateNormal];
        [closeButton setImage:[UIImage imageNamed:@"UIBlackCloseButtonPressed.png"] forState:UIControlStateHighlighted];
        
        [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.iconView = [[UIImageView alloc] initWithImage:icon];
        self.iconView.contentMode = UIViewContentModeCenter;
        
        [self addSubview:descriptionLabel];
        [self addSubview:closeButton];
        [self addSubview:iconView];
        
        [self setFrame:frame];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGFloat closeButtonSize = 29;
    CGFloat padding = 10;
    CGFloat miniPadding = 5;
    self.closeButton.frame = CGRectMake(frame
                                        .size.width - closeButtonSize - miniPadding, miniPadding, closeButtonSize, closeButtonSize);
    
    CGFloat imageWidth = self.iconView.image.size.width;
    
    self.iconView.frame = CGRectMake(0, 0, imageWidth + padding * 2, frame.size.height);
    
    CGFloat descriptionLabelWidth = closeButton.frame.origin.x - iconView.frame.size.width - padding;
    
    self.descriptionLabel.frame = CGRectMake(iconView.frame.size.width, padding, descriptionLabelWidth, frame.size.height - padding * 2);
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
