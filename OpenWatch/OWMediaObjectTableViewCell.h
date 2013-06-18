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

@interface OWMediaObjectTableViewCell : UITableViewCell

@property (nonatomic, strong) NSManagedObjectID *mediaObjectID;

@property (nonatomic, strong) STTweetLabel *titleLabel;
@property (nonatomic, strong) OWUserView *userView;

+ (CGFloat) cellHeight;
+ (CGFloat) cellWidth;

@end
