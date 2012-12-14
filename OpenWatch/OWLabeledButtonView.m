//
//  OWButtonView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWLabeledButtonView.h"
#import "OWUtilities.h"

@implementation OWLabeledButtonView
@synthesize button, textLabel;

- (id) initWithFrame:(CGRect)frame defaultImageName:(NSString*)imageName highlightedImageName:(NSString*)highlightedImageName labelName:(NSString*)labelName {
    if (self = [self initWithFrame:frame]) {
        UIImage *defaultImage = [UIImage imageNamed:imageName];
        UIImage *highlightedImage = [UIImage imageNamed:highlightedImageName];
        [self.button setImage:defaultImage forState:UIControlStateNormal];
        [self.button setImage:highlightedImage forState:UIControlStateHighlighted];
        self.textLabel.text = labelName;
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.textLabel = [[UILabel alloc] init];
        self.frame = frame;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.textLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        self.textLabel.shadowColor = [UIColor lightGrayColor];
        self.textLabel.shadowOffset = CGSizeMake(0, 1);
        self.textLabel.textColor = [OWUtilities greyTextColor];
        
        [self addSubview:textLabel];
        [self addSubview:button];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.button.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.textLabel.frame = CGRectMake(0, frame.size.height, frame.size.width, 20);
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
