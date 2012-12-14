//
//  OWRecordingTableViewCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWRecordingTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "OWRecordingController.h"
#import "OWUser.h"
#import "OWUtilities.h"
#import <QuartzCore/QuartzCore.h>

#define PADDING 9.0f

@implementation OWRecordingTableViewCell
@synthesize recordingObjectID, thumbnailImageView, titleLabel, usernameLabel, eyeImageView, actionImageView, viewsLabel, actionsLabel, tallyView, dateModifiedLabel, isLocalRecording;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, 100, 100)];
        self.thumbnailImageView.layer.masksToBounds = YES;
        self.thumbnailImageView.layer.cornerRadius = 5.0;
        self.isLocalRecording = NO;
        [self setupTallyView];
        
        CGFloat dateModifiedWidth = 180.0f;
        CGFloat dateModifiedHeight = 20.0f;
        self.dateModifiedLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-dateModifiedWidth-PADDING, self.contentView.frame.size.height-dateModifiedHeight-PADDING, dateModifiedWidth, dateModifiedHeight)];
        [self styleLabel:dateModifiedLabel];
        dateModifiedLabel.textColor = [OWUtilities greyColorWithGreyness:0.5f];
        self.dateModifiedLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        self.dateModifiedLabel.textAlignment = UITextAlignmentRight;

        CGFloat titleLabelXOrigin = thumbnailImageView.frame.origin.x + thumbnailImageView.frame.size.width + PADDING;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelXOrigin, PADDING, self.contentView.frame.size.width - titleLabelXOrigin, 100)];
        self.titleLabel.numberOfLines = 0;
        [self styleLabel:titleLabel];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        //self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        CGFloat usernameLabelHeight = 20.0f;
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, self.contentView.frame.size.height - usernameLabelHeight - PADDING, 150, usernameLabelHeight)];
        self.usernameLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        [self styleLabel:usernameLabel];
        usernameLabel.textColor = [OWUtilities greyColorWithGreyness:0.5f];
        
        
        self.backgroundView = nil;

        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:thumbnailImageView];
        [self.contentView addSubview:usernameLabel];
        [self.contentView addSubview:tallyView];
    }
    return self;
}

- (void) setupTallyView {
    self.eyeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eye.png"]];
    self.actionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"action.png"]];
    CGFloat width = 125.0f;
    CGFloat height = 20.0f;
    CGFloat labelWidth = 35.0f;
    self.tallyView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-width-PADDING, self.contentView.frame.size.height-height-PADDING, width, height)];
    self.tallyView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.eyeImageView.frame = CGRectMake(0, 0, eyeImageView.image.size.width, eyeImageView.image.size.height);
    self.viewsLabel = [[UILabel alloc] initWithFrame:CGRectMake(eyeImageView.image.size.width+PADDING, 0, labelWidth, height)];
    self.actionImageView.frame = CGRectMake(self.viewsLabel.frame.origin.x + self.viewsLabel.frame.size.width + PADDING, 0, actionImageView.image.size.width, actionImageView.image.size.height);
    self.actionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(actionImageView.frame.origin.x + actionImageView.frame.size.width + PADDING, 0, labelWidth, height)];
    [self styleLabel:viewsLabel];
    [self styleLabel:actionsLabel];

    [self.tallyView addSubview:eyeImageView];
    [self.tallyView addSubview:actionImageView];
    [self.tallyView addSubview:viewsLabel];
    [self.tallyView addSubview:actionsLabel];
}

- (void) styleLabel:(UILabel*) label {
    label.textColor = [UIColor darkTextColor];
    label.shadowColor = [UIColor lightGrayColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.backgroundColor = [UIColor clearColor];
}

- (void) setRecordingObjectID:(NSManagedObjectID *)newRecordingObjectID {
    recordingObjectID = newRecordingObjectID;
    OWManagedRecording *recording = [OWRecordingController recordingForObjectID:newRecordingObjectID];
    [tallyView removeFromSuperview];
    [dateModifiedLabel removeFromSuperview];
    if (self.isLocalRecording) {
        NSDateFormatter *dateFormatter = [OWUtilities localDateFormatter];
        self.dateModifiedLabel.text = [dateFormatter stringFromDate:recording.dateModified];
        [self.contentView addSubview:dateModifiedLabel];
    } else {
        self.actionsLabel.text = [NSString stringWithFormat:@"%d", [recording.upvotes intValue]];
        self.viewsLabel.text = [NSString stringWithFormat:@"%d", [recording.views intValue]];
        [self.contentView addSubview:tallyView];
    }
    
    [self.thumbnailImageView cancelImageRequestOperation];
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:recording.thumbnailURL] placeholderImage:[UIImage imageNamed:@"thumbnail_placeholder.png"]];
    self.titleLabel.text = recording.title;
    //[self.titleLabel sizeToFit];
    self.usernameLabel.text = recording.user.username;

    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
