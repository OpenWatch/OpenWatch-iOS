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
@synthesize bannerView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {        
        self.bannerView = [[OWBannerView alloc] initWithFrame:CGRectZero bannerImage:[UIImage imageNamed:@"side_banner_green.png"] labelText:nil];
        
        [self.contentView addSubview:bannerView];
    }
    return self;
}

- (void) refreshFrames {
    [super refreshFrames];
    CGFloat width = self.contentView.frame.size.width;
    CGFloat height = self.thumbnailImageView.frame.size.height;
    CGFloat bannerHeight = bannerView.imageView.image.size.height;
    CGFloat padding = 10.0f;
    self.bannerView.frame = CGRectMake(width - bannerView.imageView.image.size.width, height - bannerHeight - padding, bannerView.imageView.image.size.width, bannerHeight);
}


- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    [super setMediaObjectID:newMediaObjectID];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMission *mission = (OWMission*)[context existingObjectWithID:newMediaObjectID error:nil];

    if (mission.viewedValue) {
        self.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    } else {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    }
    
    UIImage *bannerImage = nil;
    NSString *text = nil;
    if (mission.usdValue > 0) {
        bannerImage = [UIImage imageNamed:@"side_banner_green.png"];
        text = [NSString stringWithFormat:@"$%.02f", mission.usdValue];
    } else {
        bannerImage = [UIImage imageNamed:@"side_banner_purple.png"];
        text = [NSString stringWithFormat:@"%d Karma", (int)mission.karmaValue];
    }
    
    self.bannerView.textLabel.text = text;
    self.bannerView.imageView.image = bannerImage;

    self.titleLabel.text = mission.title;
    [self refreshFrames];
}

@end
