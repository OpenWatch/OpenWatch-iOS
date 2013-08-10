//
//  OWMissionSelectionCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 8/9/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMissionSelectionCell.h"
#import "OWUtilities.h"
#import "UIImageView+AFNetworking.h"
#import "OWStrings.h"
#define PADDING 10.0f

@implementation OWMissionSelectionCell
@synthesize thumbnailImageView, titleLabel, expirationLabel, joinedLabel, mission;

+ (CGFloat) cellHeight {
    return 100.0f;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat thumbnailSize = [OWMissionSelectionCell cellHeight] - PADDING * 2;
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, thumbnailSize, thumbnailSize)];
        CGFloat xLabelOrigin = [OWUtilities rightOfView:thumbnailImageView] + PADDING;
        CGFloat titleLabelWidth = 190.0f;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xLabelOrigin, PADDING, titleLabelWidth, 60)];
        self.titleLabel.numberOfLines = 2;
        CGFloat smallLabelHeight = 17.0f;
        CGFloat ySmallLabelOrigin = [OWMissionSelectionCell cellHeight] - PADDING - smallLabelHeight;
        self.expirationLabel = [[UILabel alloc] initWithFrame:CGRectMake(xLabelOrigin, ySmallLabelOrigin, titleLabelWidth * 0.75, smallLabelHeight)];
        self.joinedLabel = [[UILabel alloc] initWithFrame:CGRectMake([OWUtilities rightOfView:expirationLabel], ySmallLabelOrigin, titleLabelWidth * 0.25, smallLabelHeight)];
        
        NSArray *labels = @[titleLabel, expirationLabel, joinedLabel];
        for (UILabel *label in labels) {
            label.backgroundColor = [UIColor clearColor];
        }
        [self setDefaultLabelColors];
        UIFont *smallFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
        joinedLabel.textAlignment = NSTextAlignmentRight;
        joinedLabel.font = smallFont;
        expirationLabel.font = smallFont;
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
        
        [self.contentView addSubview:thumbnailImageView];
        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:expirationLabel];
        [self.contentView addSubview:joinedLabel];
    }
    return self;
}

- (void) setDefaultLabelColors {
    self.titleLabel.textColor = [UIColor blackColor];
    self.expirationLabel.textColor = [UIColor lightGrayColor];
    self.joinedLabel.textColor = [UIColor greenColor];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    NSArray *labels = @[joinedLabel, titleLabel, expirationLabel];
    if (selected) {
        for (UILabel *label in labels) {
            label.textColor = [UIColor whiteColor];
        }
    } else {
        [self setDefaultLabelColors];
    }
}

- (void) setMission:(OWMission *)newMission {
    mission = newMission;
    
    self.titleLabel.text = mission.title;
    TTTTimeIntervalFormatter *timeFormatter = [OWUtilities timeIntervalFormatter];
    self.expirationLabel.text = [NSString stringWithFormat:@"%@ %@", EXPIRES_STRING, [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:mission.expirationDate]];
    [self.thumbnailImageView setImageWithURL:mission.thumbnailURL placeholderImage:[mission placeholderThumbnailImage]];
    if (mission.joinedValue) {
        self.joinedLabel.text = JOINED_STRING;
    } else {
        self.joinedLabel.text = nil;
    }

}

@end
