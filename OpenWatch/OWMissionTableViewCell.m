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
@synthesize bountyLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        CGFloat titleX = 120;
        CGFloat titleY = 5;
        CGFloat labelWidth = 190;
        CGFloat titleHeight = 76.0f;

        self.titleLabel.frame = CGRectMake(titleX, titleY, labelWidth, titleHeight);
        self.bountyLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 85, 100, 25)];
        self.bountyLabel.textAlignment = NSTextAlignmentRight;
        self.bountyLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.numberOfLines = 0;
        
        [self.contentView addSubview:bountyLabel];
    }
    return self;
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
    
    if (mission.usdValue > 0) {
        self.bountyLabel.text = [NSString stringWithFormat:@"$%.2f", mission.usdValue];
    } else {
        self.bountyLabel.text = [NSString stringWithFormat:@"%d Karma", (int)mission.karmaValue];
    }
    self.titleLabel.text = mission.title;
}

@end
