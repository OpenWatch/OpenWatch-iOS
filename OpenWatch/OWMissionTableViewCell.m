//
//  OWMissionTableViewCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/28/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMissionTableViewCell.h"
#import "OWMission.h"
#import "OWUtilities.h"

@implementation OWMissionTableViewCell
@synthesize bannerView, statsView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {        
        self.bannerView = [[OWBannerView alloc] initWithFrame:CGRectZero bannerImage:[UIImage imageNamed:@"side_banner_green.png"] labelText:nil];
        self.statsView = [[OWMissionStatsView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:statsView];
    }
    return self;
}

+ (UIFont*) titleLabelFont {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
}

- (void) refreshFrames {
    [super refreshFrames];
    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = self.thumbnailImageView.frame.size.height;
    CGFloat bannerHeight = bannerView.imageView.image.size.height;
    CGFloat padding = 10.0f;
    self.bannerView.frame = CGRectMake(width - bannerView.imageView.image.size.width, height - bannerHeight - padding, bannerView.imageView.image.size.width, bannerHeight);
    
    CGFloat statsViewHeight = 25;
    CGFloat statsViewWidth = 170;
    self.statsView.frame = CGRectMake(padding, height - statsViewHeight - padding, statsViewWidth, statsViewHeight);
}


- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    [super setMediaObjectID:newMediaObjectID];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMission *mission = (OWMission*)[context existingObjectWithID:newMediaObjectID error:nil];
    self.userView.user = mission.user;
    
    UIImage *bannerImage = nil;
    NSString *text = nil;
    if (mission.usdValue > 0) {
        bannerImage = [UIImage imageNamed:@"side_banner_green.png"];
        text = [NSString stringWithFormat:@"$%.02f", mission.usdValue];
    } else if (mission.karmaValue > 0) {
        bannerImage = [UIImage imageNamed:@"side_banner_purple.png"];
        text = [NSString stringWithFormat:@"%d Karma", (int)mission.karmaValue];
    }
    if (bannerImage) {
        [self.contentView addSubview:bannerView];
    } else {
        [bannerView removeFromSuperview];
    }
    
    self.bannerView.textLabel.text = text;
    self.bannerView.imageView.image = bannerImage;

    self.titleLabel.text = mission.title;
    
    TTTTimeIntervalFormatter *timeFormatter = [OWUtilities timeLeftIntervalFormatter];
    NSString *expirationString = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:mission.expirationDate];
    self.dateLabel.text = expirationString;
    [self refreshFrames];
    self.statsView.mission = mission;
}

@end
