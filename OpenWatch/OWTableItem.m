//
//  OWTableItem.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 8/9/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWTableItem.h"

@implementation OWTableItem

- (id) initWithText:(NSString *)newText image:(UIImage *)newImage {
    if (self = [super init]) {
        self.image = newImage;
        self.text = newText;
    }
    return self;
}

@end
