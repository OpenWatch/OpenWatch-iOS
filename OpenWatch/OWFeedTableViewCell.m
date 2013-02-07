//
//  OWFeedTableViewCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/30/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWFeedTableViewCell.h"
#import "OWUtilities.h"
#import "OWManagedRecording.h"
#import "OWStory.h"
#import "OWUser.h"

#define PADDING 10.0f

@implementation OWFeedTableViewCell
@synthesize tallyView, usernameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTallyView];
        [self setupUsernameLabel];
    }
    return self;
}

- (void) setupUsernameLabel {
    CGFloat usernameLabelHeight = 20.0f;
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.frame.origin.x, self.contentView.frame.size.height-usernameLabelHeight-PADDING, 95.0f, usernameLabelHeight)];
    usernameLabel.textAlignment = UITextAlignmentLeft;
    usernameLabel.textColor = [OWUtilities greyColorWithGreyness:0.5f];
    usernameLabel.backgroundColor = [UIColor clearColor];
    self.usernameLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:usernameLabel];
}

- (void) setupTallyView {
    CGFloat width = 100.0f;
    CGFloat height = 20.0f;
    self.tallyView = [[OWTallyView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-width-5, self.contentView.frame.size.height-height-PADDING, width, height)];
    self.tallyView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:tallyView];
}

- (void) setMediaObjectID:(NSManagedObjectID *)mediaObjectID {
    [super setMediaObjectID:mediaObjectID];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context existingObjectWithID:mediaObjectID error:nil];
    self.tallyView.actionsLabel.text = [NSString stringWithFormat:@"%d", [mediaObject.clicks intValue]];
    self.tallyView.viewsLabel.text = [NSString stringWithFormat:@"%d", [mediaObject.views intValue]];
    self.usernameLabel.text = mediaObject.user.username;
}

@end
