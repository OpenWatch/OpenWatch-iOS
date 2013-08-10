//
//  OWMissionSelectionCell.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 8/9/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWMission.h"

@interface OWMissionSelectionCell : UITableViewCell

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *expirationLabel;
@property (nonatomic, strong) UILabel *joinedLabel;
@property (nonatomic, strong) OWMission *mission;

+ (CGFloat) cellHeight;

@end
