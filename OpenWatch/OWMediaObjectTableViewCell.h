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
- (void) tableCell:(OWMediaObjectTableViewCell*)cell didSelectHashtag:(NSString*)hashTag;
@end

@interface OWMediaObjectTableViewCell : UITableViewCell

@property (nonatomic, strong) NSManagedObjectID *mediaObjectID;

@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) STTweetLabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) OWUserView *userView;

- (void) setupPreviewView;

@property (nonatomic, weak) id<OWMediaObjectTableViewCellDelegate> delegate;

+ (CGFloat) cellHeightForMediaObject:(OWMediaObject*)mediaObject;
+ (CGFloat) cellWidth;

+ (CGFloat) previewHeight;
+ (CGFloat) heightForTitleLabelWithText:(NSString*)text;
+ (UIFont*) titleLabelFont;

@end
