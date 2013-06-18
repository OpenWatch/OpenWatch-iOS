//
//  OWUserView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWUser.h"

enum {
    OWUserViewPictureOrientationRight,       // No scaling
    OWUserViewPictureOrientationLeft
};
typedef NSInteger OWUserViewPictureOrientation;

@interface OWUserView : UIView

@property (nonatomic) OWUserViewPictureOrientation pictureOrientation;

@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *usernameLabel;

@property (nonatomic, strong) OWUser *user;

@end
