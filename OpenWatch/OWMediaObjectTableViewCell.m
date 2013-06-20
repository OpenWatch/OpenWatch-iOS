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
#import "TTTTimeIntervalFormatter.h"

#define PADDING 5.0f

#define USER_HEIGHT 50.0f

#define TITLE_LABEL_YOFFSET 30.0f

#define CONTENT_X_OFFSET 61.0f

#define MORE_BUTTON_HEIGHT 19.0f

@implementation OWMediaObjectTableViewCell
@synthesize mediaObjectID, titleLabel, userView, previewView, delegate, moreButton, locationLabel, dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUserView];
        [self setupTitleLabel];
        [self setupPreviewView];
        [self setupMoreButton];
        [self setupLocationLabel];
        [self setupDateLabel];
        self.backgroundView = nil;
    }
    return self;
}

- (void) setupLocationLabel {
    self.locationLabel = [[UILabel alloc] init];
    self.locationLabel.backgroundColor = [UIColor clearColor];
    self.locationLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:locationLabel];
}


- (void) setupDateLabel {
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:dateLabel];
    
}

+ (CGFloat) cellWidth {
    return 320.0f;
}

+ (CGFloat) cellHeightForMediaObject:(OWMediaObject *)mediaObject {
    CGFloat totalHeight = 0.0f;
    totalHeight += [self previewHeight] + PADDING;
    totalHeight += TITLE_LABEL_YOFFSET + PADDING;
    if (mediaObject.title.length > 0) {
        totalHeight += [self heightForTitleLabelWithText:mediaObject.title];
    }
    totalHeight += MORE_BUTTON_HEIGHT + PADDING * 2;
    return totalHeight;
}

+ (CGFloat) previewHeight {
    return [OWPreviewView heightForWidth:[self cellWidth]];
}

+ (UIFont*) titleLabelFont {
    return [UIFont systemFontOfSize:20.0f];
}

+ (CGFloat) paddedWidth {
    return [self cellWidth] - PADDING * 2;
}

+ (CGFloat) insetWidth {
    return [self paddedWidth] - CONTENT_X_OFFSET;
}

+ (CGFloat) heightForTitleLabelWithText:(NSString*)text {
    if (text.length == 0) {
        return 0.0f;
    }
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake([self insetWidth], FLT_MAX);
    
    CGSize expectedLabelSize = [text sizeWithFont:[self titleLabelFont] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return expectedLabelSize.height;
}

- (void) setupMoreButton {
    self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"dots.png"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:moreButton];
}

- (void) moreButtonPressed:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(moreButtonPressedForTableCell:)]) {
        [delegate moreButtonPressedForTableCell:self];
    }
}

- (void) setupPreviewView {
    self.previewView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:previewView];
}

- (void) setupUserView {
    self.userView = [[OWUserView alloc] initWithFrame:CGRectZero];
    self.userView.verticalAlignment = OWUserViewLabelVerticalAlignmentTop;
    [self.contentView addSubview:userView];

}

- (void) refreshFrames {
    CGFloat cellWidth = [OWMediaObjectTableViewCell cellWidth];
    CGFloat paddedWidth = [OWMediaObjectTableViewCell paddedWidth];
    CGFloat insetWidth = [OWMediaObjectTableViewCell insetWidth];
    CGFloat previewHeight = [OWMediaObjectTableViewCell previewHeight];
    self.previewView.frame = CGRectMake(0, 0, cellWidth, previewHeight);
    CGFloat userViewYOrigin = [OWUtilities bottomOfView:previewView] + PADDING;
    self.userView.frame = CGRectMake(PADDING, userViewYOrigin, paddedWidth, USER_HEIGHT);
    CGFloat locationLabelWidth = 130.0f;
    self.locationLabel.frame = CGRectMake(cellWidth - locationLabelWidth - PADDING, userViewYOrigin, locationLabelWidth, self.userView.usernameLabel.frame.size.height);
    
    CGFloat xOffset = PADDING + CONTENT_X_OFFSET; 
    CGFloat yOffset = TITLE_LABEL_YOFFSET + [OWUtilities bottomOfView:previewView];
    
    CGFloat titleLabelHeight = [OWMediaObjectTableViewCell heightForTitleLabelWithText:self.titleLabel.text];
    self.titleLabel.frame = CGRectMake(xOffset, yOffset, insetWidth, titleLabelHeight);
    
    
    CGFloat bottomRowYOrigin = [OWUtilities bottomOfView:titleLabel] + PADDING;
    
    CGFloat moreButtonWidth = 50.0f;
    self.moreButton.frame = CGRectMake([OWMediaObjectTableViewCell cellWidth] - moreButtonWidth - PADDING, bottomRowYOrigin, moreButtonWidth, MORE_BUTTON_HEIGHT);
    
    
    self.dateLabel.frame = CGRectMake(xOffset, bottomRowYOrigin, 200, MORE_BUTTON_HEIGHT);
}

- (void) setupTitleLabel {
    self.titleLabel = [[STTweetLabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [OWMediaObjectTableViewCell titleLabelFont];
    self.titleLabel.colorHashtag = [UIColor redColor];
    self.titleLabel.verticalAlignment = STVerticalAlignmentMiddle;
    [self.contentView addSubview:titleLabel];
    
    STLinkCallbackBlock callbackBlock = ^(STLinkActionType actionType, NSString *link) {
        if (actionType == STLinkActionTypeHashtag) {
            NSLog(@"Hashtag: %@", link);
            NSString *rawTag = [link stringByReplacingOccurrencesOfString:@"#" withString:@""];
            if (delegate && [delegate respondsToSelector:@selector(tableCell:didSelectHashtag:)]) {
                [delegate tableCell:self didSelectHashtag:rawTag];
            }
        }    
    };
    self.titleLabel.callbackBlock = callbackBlock;
}

- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    mediaObjectID = newMediaObjectID;
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context existingObjectWithID:mediaObjectID error:nil];
    
    TTTTimeIntervalFormatter *timeFormatter = [OWUtilities timeIntervalFormatter];
    
    self.titleLabel.text = mediaObject.title;
    
    if (mediaObject.metroCode) {
        self.locationLabel.text = mediaObject.metroCode;
    }
    self.dateLabel.text = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:mediaObject.modifiedDate];
    
    self.userView.user = mediaObject.user;
    
    
    [self refreshFrames];
}

@end
