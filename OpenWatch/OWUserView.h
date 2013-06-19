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
    OWUserViewLabelVerticalAlignmentTop,
    OWUserViewLabelVerticalAlignmentCenter, // default
};
typedef NSInteger OWUserViewLabelVerticalAlignment;


@interface OWUserView : UIView

@property (nonatomic) OWUserViewLabelVerticalAlignment verticalAlignment;

@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *usernameLabel;

@property (nonatomic, strong) OWUser *user;

@end
