//
//  OWUserProfileView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/3/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWUser.h"

@interface OWUserProfileView : UIView

@property (nonatomic, strong) OWUser *user;
@property (nonatomic, strong) UIImage *image;

@end
