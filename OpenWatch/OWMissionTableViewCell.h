//
//  OWMissionTableViewCell.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/28/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMediaObjectTableViewCell.h"
#import "OWThumbnailCell.h"
#import "OWBannerView.h"

@interface OWMissionTableViewCell : OWThumbnailCell

@property (nonatomic, strong) OWBannerView *bannerView;

@end
