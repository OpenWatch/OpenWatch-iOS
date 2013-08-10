//
//  OWTableItem.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 8/9/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWTableItem : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIImage *image;

- (id) initWithText:(NSString*)newText image:(UIImage*)newImage;

@end
