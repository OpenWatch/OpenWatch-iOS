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
@synthesize mediaObjectID, thumbnailImageView, titleLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupThumbnailImageView];
        [self setupTitleLabel];

        self.backgroundView = nil;
    }
    return self;
}

- (void) setupTitleLabel {
    CGFloat titleLabelXOrigin = [OWUtilities rightOfView:thumbnailImageView] + PADDING;
    CGFloat titleLabelWidth = self.contentView.frame.size.width - titleLabelXOrigin;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelXOrigin, 0, titleLabelWidth, 100)];
    self.titleLabel.numberOfLines = 3;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.contentView addSubview:titleLabel];
}

- (void) setupThumbnailImageView {
    self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, 100, 100)];
    self.thumbnailImageView.layer.masksToBounds = YES;
    self.thumbnailImageView.layer.cornerRadius = 5.0;
    self.thumbnailImageView.layer.shouldRasterize = YES;
    [self.contentView addSubview:thumbnailImageView];
}


- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    mediaObjectID = newMediaObjectID;
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context objectWithID:mediaObjectID];
    self.titleLabel.text = mediaObject.title;
    [self.thumbnailImageView setImageWithURL:mediaObject.thumbnailURL placeholderImage:[UIImage imageNamed:@"thumbnail_placeholder.png"]];
}

@end
