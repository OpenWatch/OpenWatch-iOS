//
//  OWDashboardItem.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/3/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWDashboardItem : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *title;

- (id) initWithTitle:(NSString*)newTitle image:(UIImage*)newImage;

@end
