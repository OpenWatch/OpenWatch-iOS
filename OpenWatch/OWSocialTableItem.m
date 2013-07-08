//
//  OWSocialTableItem.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/8/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWSocialTableItem.h"

@implementation OWSocialTableItem
@synthesize socialSwitch, image, text;

- (id) initWithSwitch:(UISwitch*)newSocialSwitch image:(UIImage*)newImage text:(NSString*)newText {
    if (self = [super init]) {
        self.socialSwitch = newSocialSwitch;
        self.image = newImage;
        self.text = newText;
    }
    return self;
}

@end
