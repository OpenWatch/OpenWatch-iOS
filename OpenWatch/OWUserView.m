//
//  OWUserView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWUserView.h"
#import "OWUtilities.h"
#import "OWUser.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@implementation OWUserView
@synthesize profileImageView, usernameLabel, user, verticalAlignment;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.profileImageView = [[UIImageView alloc] init];
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        profileImageView.layer.cornerRadius = 10;
        profileImageView.layer.shouldRasterize = YES;
        profileImageView.clipsToBounds = YES;
        self.usernameLabel = [[UILabel alloc] init];
        self.usernameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.usernameLabel.textColor = [UIColor redColor];
        self.usernameLabel.adjustsFontSizeToFitWidth = YES;
        self.usernameLabel.backgroundColor = [UIColor clearColor];
        self.usernameLabel.numberOfLines = 1;
        
        self.verticalAlignment = OWUserViewLabelVerticalAlignmentCenter;
        [self setFrame:frame];
        [self addSubview:profileImageView];
        [self addSubview:usernameLabel];
    }
    return self;
}

- (void) layoutViews {
    CGRect frame = self.frame;


    self.profileImageView.frame = CGRectMake(0, 0, frame.size.height, frame.size.height);
    CGFloat labelWidth = frame.size.width - frame.size.height;
    self.profileImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.usernameLabel.frame = CGRectMake([OWUtilities rightOfView:profileImageView] + 10, 0, labelWidth, frame.size.height);
    self.usernameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    if (verticalAlignment == OWUserViewLabelVerticalAlignmentTop) {
        [self.usernameLabel sizeToFit];
    }
}

- (void) setVerticalAlignment:(OWUserViewLabelVerticalAlignment)newVerticalAlignment {
    verticalAlignment = newVerticalAlignment;
    [self layoutViews];
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self layoutViews];
}

- (void) setUser:(OWUser *)newUser {
    user = newUser;
    [self.profileImageView setImageWithURL:user.thumbnailURL placeholderImage:[UIImage imageNamed:@"user_placeholder.png"]];
    self.usernameLabel.text = user.username;
    [self layoutViews];
}



@end
