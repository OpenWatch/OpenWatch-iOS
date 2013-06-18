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
#import "OWAudio.h"
#import "OWPhoto.h"
#import "OWManagedRecording.h"
#import "OWInvestigation.h"
#import "OWPreviewView.h"

#define PADDING 5.0f

@implementation OWMediaObjectTableViewCell
@synthesize mediaObjectID, titleLabel, userView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupTitleLabel];
        [self setupUserView];
        self.backgroundView = nil;
    }
    return self;
}

- (void) setupUserView {
    CGFloat width = 200.0f;
    CGFloat height = 30.0f;
    self.userView = [[OWUserView alloc] initWithFrame:CGRectMake([OWMediaObjectTableViewCell cellWidth] - PADDING - width, [OWMediaObjectTableViewCell cellHeight] - height, width, height)];
    self.userView.pictureOrientation = OWUserViewPictureOrientationRight;
    [self.contentView addSubview:userView];

}

+ (CGFloat) cellHeight {
    return 300.0f;
}

+ (CGFloat) cellWidth {
    return 320.0f;
}

- (void) setupTitleLabel {
    CGFloat titleLabelXOrigin = PADDING;
    CGFloat titleLabelWidth = [OWMediaObjectTableViewCell cellWidth] / 2;
    CGFloat titleLabelHeight = 25.0f;
    self.titleLabel = [[STTweetLabel alloc] initWithFrame:CGRectMake(titleLabelXOrigin, [OWMediaObjectTableViewCell cellHeight] - titleLabelHeight, titleLabelWidth, titleLabelHeight)];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [self.contentView addSubview:titleLabel];
    
    STLinkCallbackBlock callbackBlock = ^(STLinkActionType actionType, NSString *link) {
        if (actionType == STLinkActionTypeHashtag) {
            NSLog(@"Hashtag: %@", link);

        }    
    };
    self.titleLabel.callbackBlock = callbackBlock;
}


- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    mediaObjectID = newMediaObjectID;
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context existingObjectWithID:mediaObjectID error:nil];
    
    NSString *title = mediaObject.title;
    
    if (title.length == 0) {
        NSDateFormatter *dateFormatter = [OWUtilities humanizedDateFormatter];
        if (mediaObject.firstPostedDate) {
            self.titleLabel.text = [dateFormatter stringFromDate:mediaObject.firstPostedDate];
        } else if (mediaObject.modifiedDate) {
            self.titleLabel.text = [dateFormatter stringFromDate:mediaObject.modifiedDate];
        } else {
            self.titleLabel.text = @"Untitled";
        }
    } else {
        self.titleLabel.text = title;
    }
    
    self.userView.user = mediaObject.user;
}

@end
