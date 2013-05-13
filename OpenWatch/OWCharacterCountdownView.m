//
//  OWCharacterCountdownView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/10/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWCharacterCountdownView.h"
#import <QuartzCore/QuartzCore.h>

#define kGreenThreshold 100
#define kYellowThreshold 50
#define kOrangeThreshold 15

@implementation OWCharacterCountdownView
@synthesize maxCharacters, countLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.maxCharacters = 254;
        self.countLabel = [[UILabel alloc] init];
        self.countLabel.backgroundColor = [UIColor clearColor];
        self.countLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        self.countLabel.layer.opacity = 0.0f;
        [self updateText:@""];
        [self addSubview:countLabel];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.countLabel.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (BOOL) updateText:(NSString *)text {
    NSUInteger count = text.length;
    if (count > maxCharacters) {
        count = maxCharacters;
    }
    NSUInteger charactersLeft = maxCharacters - count;
    self.countLabel.text = [NSString stringWithFormat:@"%d", charactersLeft];
    if (charactersLeft <= kGreenThreshold && self.countLabel.layer.opacity < 1.0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.countLabel.layer.opacity = 1.0;
        }];
    } else if (charactersLeft > kGreenThreshold && self.countLabel.layer.opacity > 0.0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.countLabel.layer.opacity = 0.0f;
        }];
    }
    if (charactersLeft >= kYellowThreshold) {
        self.countLabel.textColor = [UIColor greenColor];
    } else if (charactersLeft < kYellowThreshold && charactersLeft > kOrangeThreshold) {
        self.countLabel.textColor = [UIColor yellowColor];
    } else if (charactersLeft <= kOrangeThreshold && charactersLeft > 0) {
        self.countLabel.textColor = [UIColor orangeColor];
    } else if (charactersLeft == 0) {
        self.countLabel.textColor = [UIColor redColor];
        return NO;
    }
    return YES;
}

@end
