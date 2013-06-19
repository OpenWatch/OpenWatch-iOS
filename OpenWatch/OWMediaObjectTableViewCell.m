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

#define USER_HEIGHT 45.0f

#define CONTENT_X_OFFSET 54.0f

#define MORE_BUTTON_HEIGHT 17.0f

@implementation OWMediaObjectTableViewCell
@synthesize mediaObjectID, titleLabel, userView, previewView, delegate, moreButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUserView];
        [self setupTitleLabel];
        [self setupPreviewView];
        [self setupMoreButton];
        self.backgroundView = nil;
    }
    return self;
}

+ (CGFloat) cellWidth {
    return 320.0f;
}

+ (CGFloat) cellHeightForMediaObject:(OWMediaObject *)mediaObject {
    CGFloat totalHeight = 0.0f;
    totalHeight += [self previewHeight] + PADDING;
    totalHeight += USER_HEIGHT + PADDING;
    totalHeight += [self heightForTitleLabelWithText:mediaObject.titleOrHumanizedDateString] + PADDING;
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
    [self.contentView addSubview:userView];

}

- (void) refreshFrames {
    CGFloat cellWidth = [OWMediaObjectTableViewCell cellWidth];
    CGFloat paddedWidth = [OWMediaObjectTableViewCell paddedWidth];
    CGFloat insetWidth = [OWMediaObjectTableViewCell insetWidth];
    CGFloat previewHeight = [OWMediaObjectTableViewCell previewHeight];
    self.previewView.frame = CGRectMake(0, 0, cellWidth, previewHeight);
    self.userView.frame = CGRectMake(PADDING, [OWUtilities bottomOfView:previewView] + PADDING, paddedWidth, USER_HEIGHT);
    
    CGFloat titleLabelHeight = [OWMediaObjectTableViewCell heightForTitleLabelWithText:self.titleLabel.text];
    self.titleLabel.frame = CGRectMake(PADDING + CONTENT_X_OFFSET, [OWUtilities bottomOfView:userView] + PADDING, insetWidth, titleLabelHeight);
    
    CGFloat moreButtonWidth = 50.0f;
    self.moreButton.frame = CGRectMake([OWMediaObjectTableViewCell cellWidth] - moreButtonWidth - PADDING, [OWUtilities bottomOfView:titleLabel] + PADDING, moreButtonWidth, MORE_BUTTON_HEIGHT);
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
    
    NSString *title = [mediaObject titleOrHumanizedDateString];
    
    self.titleLabel.text = title;
    
    self.userView.user = mediaObject.user;
    
    [self refreshFrames];
}

@end
