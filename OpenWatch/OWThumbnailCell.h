//
//  OWThumbnailCell.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/17/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMediaObjectTableViewCell.h"

@interface OWThumbnailCell : OWMediaObjectTableViewCell

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UIImageView *thumbnailImageView;


@end
