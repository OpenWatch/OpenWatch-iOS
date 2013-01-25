//
//  OWTallyView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/18/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWTallyView.h"
#import "OWUtilities.h"

#define PADDING 6.0f

@implementation OWTallyView
@synthesize actionImageView, actionsLabel, viewsLabel, eyeImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat labelWidth = 23.0f;
        CGFloat height = frame.size.height;
        self.eyeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eye.png"]];
        self.actionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"action.png"]];
        self.eyeImageView.frame = CGRectMake(0, 0, eyeImageView.image.size.width, eyeImageView.image.size.height);
        self.viewsLabel = [[UILabel alloc] initWithFrame:CGRectMake(eyeImageView.image.size.width+PADDING, 0, labelWidth, height)];
        self.actionImageView.frame = CGRectMake(self.viewsLabel.frame.origin.x + self.viewsLabel.frame.size.width + PADDING, 0, actionImageView.image.size.width, actionImageView.image.size.height);
        self.actionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(actionImageView.frame.origin.x + actionImageView.frame.size.width + PADDING, 0, labelWidth, height)];
        self.eyeImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.viewsLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.actionImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.actionsLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.actionsLabel.backgroundColor = [UIColor clearColor];
        self.viewsLabel.backgroundColor = [UIColor clearColor];
        
        self.viewsLabel.adjustsFontSizeToFitWidth = YES;
        self.viewsLabel.adjustsLetterSpacingToFitWidth = YES;
        self.actionsLabel.adjustsLetterSpacingToFitWidth = YES;
        self.actionsLabel.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview:eyeImageView];
        [self addSubview:actionImageView];
        [self addSubview:viewsLabel];
        [self addSubview:actionsLabel];
    }
    return self;
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
