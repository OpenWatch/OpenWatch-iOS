//
//  UINavigationBar+DropShadow.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/24/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "UINavigationBar+DropShadow.h"
#import "OWUtilities.h"

@implementation UINavigationBar (DropShadow)

-(void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [OWUtilities applyShadowToView:self];
}

@end
