//
//  OWBannerView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWBannerView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

- (id)initWithFrame:(CGRect)frame bannerImage:(UIImage*)bannerImage labelText:(NSString*)labelText;

@end
