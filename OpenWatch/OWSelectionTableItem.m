//
//  OWSelectionTableItem.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 8/9/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWSelectionTableItem.h"

@implementation OWSelectionTableItem

- (id) initWithText:(NSString*)newText image:(UIImage*)newImage target:(id)newTarget selector:(SEL)newSelector {
    if (self = [super initWithText:newText image:newImage]) {
        self.target = newTarget;
        self.selector = newSelector;
    }
    return self;
}

@end
