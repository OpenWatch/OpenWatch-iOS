//
//  OWDashboardItem.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/3/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWDashboardItem.h"
#import "OWDashboardTableViewCell.h"

@implementation OWDashboardItem
@synthesize title, image, target, selector;

- (id) initWithTitle:(NSString *)newTitle image:(UIImage *)newImage target:(id)newTarget selector:(SEL)newSelector {
    if (self = [super init]) {
        self.title = newTitle;
        self.image = newImage;
        self.target = newTarget;
        self.selector = newSelector;
    }
    return self;
}

+ (NSString*) cellIdentifier {
    return @"OWDashboardTableViewCell";
}

+ (Class) cellClass {
    return [OWDashboardTableViewCell class];
}

@end
