//
//  OWSocialTableItem.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/8/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWTableItem.h"

@interface OWSocialTableItem : OWTableItem

@property (nonatomic, strong) UISwitch *socialSwitch;

- (id) initWithSwitch:(UISwitch*)newSocialSwitch image:(UIImage*)newImage text:(NSString*)newText;

@end
