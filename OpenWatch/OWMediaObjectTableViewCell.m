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

#define USER_HEIGHT 30.0f

@implementation OWMediaObjectTableViewCell
@synthesize mediaObjectID, titleLabel, userView, previewView, delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUserView];
        [self setupTitleLabel];
        [self setupPreviewView];
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

+ (CGFloat) heightForTitleLabelWithText:(NSString*)text {
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake([self paddedWidth], FLT_MAX);
    
    CGSize expectedLabelSize = [text sizeWithFont:[self titleLabelFont] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return expectedLabelSize.height;
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
    CGFloat previewHeight = [OWMediaObjectTableViewCell previewHeight];
    self.previewView.frame = CGRectMake(0, 0, cellWidth, previewHeight);
    self.userView.frame = CGRectMake(PADDING, [OWUtilities bottomOfView:previewView] + PADDING, paddedWidth, USER_HEIGHT);
    
    CGFloat titleLabelHeight = [OWMediaObjectTableViewCell heightForTitleLabelWithText:self.titleLabel.text];
    self.titleLabel.frame = CGRectMake(PADDING, [OWUtilities bottomOfView:userView] + PADDING, paddedWidth, titleLabelHeight);
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
