//
//  OWUserProfileView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/3/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWUserProfileView.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@interface OWUserProfileView()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation OWUserProfileView
@synthesize imageView, user, image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.cornerRadius = 10;
        self.imageView.layer.shouldRasterize = YES;
        self.imageView.clipsToBounds = YES;
        [self setFrame:frame];
        [self addSubview:imageView];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void) setImage:(UIImage *)newImage {
    image = newImage;
    self.imageView.image = image;
}


- (void) setUser:(OWUser *)newUser {
    user = newUser;
    UIImage *placeholder = [UIImage imageNamed:@"user_placeholder.png"];
    if (!user.thumbnailURL) {
        self.imageView.image = placeholder;
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:user.thumbnailURL];
    __weak __typeof(&*self)weakSelf = self;

    [self.imageView setImageWithURLRequest:request placeholderImage:placeholder success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *localImage) {
        weakSelf.image = localImage;
        weakSelf.imageView.image = localImage;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Error fetching user image: %@", error.userInfo);
    }];
}

@end
