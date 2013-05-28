//
//  OWMissionTableViewCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/28/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMissionTableViewCell.h"
#import "OWMission.h"

@implementation OWMissionTableViewCell
@synthesize bountyLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bountyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        [self.contentView addSubview:bountyLabel];
    }
    return self;
}


- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    [super setMediaObjectID:newMediaObjectID];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMission *mission = (OWMission*)[context existingObjectWithID:newMediaObjectID error:nil];
    self.bountyLabel.text = [NSString stringWithFormat:@"$%.2f", mission.bountyValue];
}

@end
