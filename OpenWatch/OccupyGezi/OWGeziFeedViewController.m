//
//  OWGeziFeedViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/26/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWGeziFeedViewController.h"

@interface OWGeziFeedViewController ()

@end

@implementation OWGeziFeedViewController

- (UIImage*) logoImage {
    return [UIImage imageNamed:@"occupygezi_nav.png"];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.badgeView) {
        [self.badgeView removeFromSuperview];
        self.badgeView = nil;
    }
}

- (void) didSelectFeedWithName:(NSString *)feedName type:(OWFeedType)type {
    if ([feedName isEqualToString:self.selectedFeedString]) {
        return;
    }
    if ([feedName isEqualToString:@"occupygezi"] || !feedName) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[self logoImage]];
        imageView.frame = CGRectMake(0, 0, 140, 25);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationItem.titleView = imageView;
    } else {
        self.title = feedName;
        self.navigationItem.titleView = nil;
    }
    if (type == kOWFeedTypeFrontPage) {
        [self didSelectFeedWithName:@"occupygezi" type:kOWFeedTypeTag pageNumber:1];
        return;
    }
    [self didSelectFeedWithName:feedName type:type pageNumber:1];
}

@end
