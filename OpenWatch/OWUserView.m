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

@implementation OWUserView
@synthesize profileImageView, usernameLabel, user;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.profileImageView = [[UIImageView alloc] init];
        self.usernameLabel = [[UILabel alloc] init];
        self.usernameLabel.backgroundColor = [UIColor clearColor];
        [self setFrame:frame];
        [self addSubview:profileImageView];
        [self addSubview:usernameLabel];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.profileImageView.frame = CGRectMake(0, 0, frame.size.height, frame.size.height);
    CGFloat labelWidth = frame.size.width - frame.size.height;
    self.profileImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.usernameLabel.frame = CGRectMake([OWUtilities rightOfView:profileImageView] + 10, 0, labelWidth, frame.size.height);
    self.usernameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

- (void) setUser:(OWUser *)newUser {
    user = newUser;
    [self.profileImageView setImageWithURL:user.thumbnailURL placeholderImage:[UIImage imageNamed:@"user_placeholder.png"]];
    self.usernameLabel.text = user.username;
}



@end
