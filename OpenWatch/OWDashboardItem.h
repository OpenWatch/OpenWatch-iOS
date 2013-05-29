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
@property (nonatomic) SEL selector;
@property (nonatomic, weak) id target;

- (id) initWithTitle:(NSString*)newTitle image:(UIImage*)newImage target:(id) newTarget selector:(SEL)newSelector;

+ (NSString*) cellIdentifier;
+ (Class) cellClass;

@end
