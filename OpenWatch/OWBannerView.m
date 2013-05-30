//
//  OWBannerView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWBannerView.h"

@implementation OWBannerView
@synthesize imageView, textLabel;

- (id)initWithFrame:(CGRect)frame bannerImage:(UIImage*)bannerImage labelText:(NSString *)labelText {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithImage:bannerImage];
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        self.textLabel.shadowColor = [UIColor blackColor];
        self.textLabel.shadowOffset = CGSizeMake(0, -1);
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.text = labelText;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:imageView];
        [self addSubview:textLabel];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    if (self = [self initWithFrame:frame bannerImage:nil labelText:nil]) {
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGFloat imageWidth = imageView.image.size.width;
    CGFloat imageHeight = imageView.image.size.height;
    self.imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    CGFloat textLabelX = imageWidth * 0.2;
    CGFloat textLabelY = imageHeight;
    self.textLabel.frame = CGRectMake(textLabelX, textLabelY, imageWidth - textLabelX * 2, imageHeight - textLabelY * 2);
}

@end
