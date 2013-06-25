//
//  OWMediaObjectTableViewCell.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWMediaObject.h"
#import "OWUserView.h"
#import "STTweetLabel.h"

@class OWMediaObjectTableViewCell;

@protocol OWMediaObjectTableViewCellDelegate <NSObject>
@optional
- (void) tableCell:(OWMediaObjectTableViewCell*)cell didSelectHashtag:(NSString*)hashTag;
- (void) moreButtonPressedForTableCell:(OWMediaObjectTableViewCell*)cell;
@end

@interface OWMediaObjectTableViewCell : UITableViewCell

@property (nonatomic, strong) NSManagedObjectID *mediaObjectID;

@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) STTweetLabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) OWUserView *userView;
@property (nonatomic, strong) UIButton *moreButton;

- (void) setupPreviewView;
- (void) refreshFrames;

@property (nonatomic, weak) id<OWMediaObjectTableViewCellDelegate> delegate;

+ (CGFloat) cellHeightForMediaObject:(OWMediaObject*)mediaObject;
+ (CGFloat) cellWidth;

+ (CGFloat) previewHeight;
+ (CGFloat) heightForTitleLabelWithText:(NSString*)text;
+ (UIFont*) titleLabelFont;
+ (CGFloat) paddedWidth;
+ (CGFloat) contentXOffset;
+ (CGFloat) titleLabelYOffset;

@end
