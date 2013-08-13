//
//  OWMissionStatsView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 8/13/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMissionStatsView.h"
#import "OWUtilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation OWMissionStatsView
@synthesize peopleCountLabel, peopleImageView, mediaCountLabel, mediaImageView, mission;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.peopleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"112-group.png"]];
        self.peopleImageView.contentMode = UIViewContentModeCenter;
        self.mediaImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"160-voicemail-2.png"]];
        self.mediaImageView.contentMode = UIViewContentModeCenter;
        self.mediaCountLabel = [[UILabel alloc] init];
        self.peopleCountLabel = [[UILabel alloc] init];
        
        NSArray *labels = @[mediaCountLabel, peopleCountLabel];
        for (UILabel *label in labels) {
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:23.0f];
            label.textAlignment = NSTextAlignmentCenter;
        }
        
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        self.layer.cornerRadius = 5.0f;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        [self addSubview:peopleCountLabel];
        [self addSubview:mediaCountLabel];
        [self addSubview:peopleImageView];
        [self addSubview:mediaImageView];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGFloat padding = 5.0f;
    CGFloat frameHeight = frame.size.height;
    self.peopleImageView.frame = CGRectMake(padding, 0, peopleImageView.image.size.width, frameHeight);
    CGFloat labelWidth = 45.0f;
    self.peopleCountLabel.frame = CGRectMake([OWUtilities rightOfView:peopleImageView] + padding, 0, labelWidth, frameHeight);
    self.mediaImageView.frame = CGRectMake([OWUtilities rightOfView:peopleCountLabel] + padding, 0, self.mediaImageView.image.size.width,frameHeight);
    self.mediaCountLabel.frame = CGRectMake([OWUtilities rightOfView:mediaImageView] + padding, 0, labelWidth, frameHeight);
}

- (void) setMission:(OWMission *)newMission {
    mission = newMission;
    
    self.peopleCountLabel.text = mission.agents.description;
    self.mediaCountLabel.text = mission.submissions.description;
}

@end
