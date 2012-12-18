//
//  OWUtilities.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/29/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WEPopoverController.h"

@interface OWUtilities : NSObject

+ (UIColor*) fabricBackgroundPattern;
+ (UIColor*) greyTextColor;
+ (UIColor*) navigationBarColor;
+ (UIColor*) doneButtonColor;
+ (UIColor*) greyColorWithGreyness:(CGFloat)greyness;

+ (void) styleLabel:(UILabel*) label;

+ (NSDateFormatter*) utcDateFormatter;
+ (NSDateFormatter*) localDateFormatter;
+ (NSString*) apiBaseURLString;
+ (NSString*) captureBaseURLString;

+ (CGFloat) bottomOfView:(UIView*)view;
+ (CGFloat) rightOfView:(UIView*)view;


+ (WEPopoverContainerViewProperties *)improvedContainerViewProperties;

@end
