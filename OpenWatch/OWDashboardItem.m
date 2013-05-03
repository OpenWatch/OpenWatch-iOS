//
//  OWDashboardItem.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/3/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWDashboardItem.h"

@implementation OWDashboardItem
@synthesize title, image;

- (id) initWithTitle:(NSString *)newTitle image:(UIImage *)newImage {
    if (self = [super init]) {
        self.title = newTitle;
        self.image = newImage;
    }
    return self;
}

@end
