//
//  UINavigationBar+DropShadow.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/24/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "UINavigationBar+DropShadow.h"
#import <QuartzCore/QuartzCore.h>

@implementation UINavigationBar (DropShadow)

-(void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 1;
    self.layer.shadowOffset = CGSizeMake(0,1);
    CGRect shadowPath = CGRectMake(self.layer.bounds.origin.x - 10, self.layer.bounds.size.height - 6, self.layer.bounds.size.width + 20, 4);
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowPath].CGPath;
    self.layer.shouldRasterize = YES;
}

@end
