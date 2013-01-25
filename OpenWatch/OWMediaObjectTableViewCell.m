//
//  OWMediaObjectTableViewCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWMediaObjectTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "OWRecordingController.h"
#import "OWUser.h"
#import "OWStory.h"
#import "OWUtilities.h"
#import <QuartzCore/QuartzCore.h>
#import "OWStrings.h"

#define PADDING 10.0f

@implementation OWMediaObjectTableViewCell
@synthesize mediaObjectID, thumbnailImageView, titleLabel, usernameLabel, tallyView, dateModifiedLabel, isLocalRecording;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, 100, 100)];
        self.thumbnailImageView.layer.masksToBounds = YES;
        self.thumbnailImageView.layer.cornerRadius = 5.0;
        self.thumbnailImageView.layer.shouldRasterize = YES;
        self.isLocalRecording = NO;
        [self setupTallyView];
        
        CGFloat dateModifiedWidth = 180.0f;
        CGFloat dateModifiedHeight = 20.0f;
        self.dateModifiedLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-dateModifiedWidth-PADDING, self.contentView.frame.size.height-dateModifiedHeight-PADDING, dateModifiedWidth, dateModifiedHeight)];
        [OWUtilities styleLabel:dateModifiedLabel];
        dateModifiedLabel.textColor = [OWUtilities greyColorWithGreyness:0.5f];
        self.dateModifiedLabel.textAlignment = UITextAlignmentRight;

        CGFloat titleLabelXOrigin = [OWUtilities rightOfView:thumbnailImageView] + PADDING;
        CGFloat titleLabelWidth = self.contentView.frame.size.width - titleLabelXOrigin;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelXOrigin, 0, titleLabelWidth, 100)];
        self.titleLabel.numberOfLines = 3;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        CGFloat usernameLabelHeight = 20.0f;
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelXOrigin, self.contentView.frame.size.height-usernameLabelHeight-PADDING, 95.0f, usernameLabelHeight)];
        usernameLabel.textAlignment = UITextAlignmentLeft;
        usernameLabel.textColor = [OWUtilities greyColorWithGreyness:0.5f];
        usernameLabel.backgroundColor = [UIColor clearColor];
        self.usernameLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        self.backgroundView = nil;

        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:thumbnailImageView];
        [self.contentView addSubview:usernameLabel];
        [self.contentView addSubview:tallyView];
    }
    return self;
}

- (void) setupTallyView {
    CGFloat width = 100.0f;
    CGFloat height = 20.0f;
    self.tallyView = [[OWTallyView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-width-5, self.contentView.frame.size.height-height-PADDING, width, height)];
    self.tallyView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
}


- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    mediaObjectID = newMediaObjectID;
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context objectWithID:mediaObjectID];
    [tallyView removeFromSuperview];
    [dateModifiedLabel removeFromSuperview];
    NSString *thumbnailURLString = nil;
    if (isLocalRecording) {
        OWLocalRecording *recording = (OWLocalRecording*)mediaObject;
        NSDateFormatter *dateFormatter = [OWUtilities localDateFormatter];
        self.dateModifiedLabel.text = [dateFormatter stringFromDate:recording.modifiedDate];
        [self.contentView addSubview:dateModifiedLabel];
        thumbnailURLString = recording.thumbnailURL;
    } else {
        if ([mediaObject isKindOfClass:[OWManagedRecording class]]) {
            OWManagedRecording *recording = (OWManagedRecording*)mediaObject;
            thumbnailURLString = recording.thumbnailURL;
        } else if ([mediaObject isKindOfClass:[OWStory class]]) {
            thumbnailURLString = mediaObject.user.thumbnailURLString;
        }
        self.tallyView.actionsLabel.text = [NSString stringWithFormat:@"%d", [mediaObject.clicks intValue]];
        self.tallyView.viewsLabel.text = [NSString stringWithFormat:@"%d", [mediaObject.views intValue]];
        [self.contentView addSubview:tallyView];
    }
    
    
    [self.thumbnailImageView cancelImageRequestOperation];
    [self.thumbnailImageView setImageWithURL:[NSURL URLWithString:thumbnailURLString] placeholderImage:[UIImage imageNamed:@"thumbnail_placeholder.png"]];
    self.titleLabel.text = mediaObject.title;
    //[self.titleLabel sizeToFit];
    self.usernameLabel.text = mediaObject.user.username;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
