//
//  OWSelectionTableItem.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 8/9/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWTableItem.h"

@interface OWSelectionTableItem : OWTableItem

@property (nonatomic) SEL selector;
@property (nonatomic, weak) id target;

- (id) initWithText:(NSString*)newText image:(UIImage*)newImage target:(id)newTarget selector:(SEL)newSelector;

@end
