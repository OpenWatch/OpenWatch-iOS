//
//  OWUtilities.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/29/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WEPopoverController.h"
#import "TTTTimeIntervalFormatter.h"

@interface OWUtilities : NSObject

+ (UIColor*) stoneBackgroundPattern;
+ (UIColor*) greyTextColor;
+ (UIColor*) navigationBarColor;
+ (UIColor*) doneButtonColor;
+ (UIColor*) greyColorWithGreyness:(CGFloat)greyness;
+ (UIColor*) textFieldTextColor;

+ (UIImage*) navigationBarBackgroundImage;

+ (void) logFrame:(CGRect)frame;

+ (void) styleLabel:(UILabel*) label;
+ (void) applyShadowToView:(UIView*)view;

+ (NSDateFormatter*) utcDateFormatter;
+ (NSDateFormatter*) humanizedDateFormatter;
+ (TTTTimeIntervalFormatter*) timeIntervalFormatter;
+ (NSString*) apiBaseURLString;
+ (NSString*) captureBaseURLString;
+ (NSString*) websiteBaseURLString;

+ (CGFloat) bottomOfView:(UIView*)view;
+ (CGFloat) rightOfView:(UIView*)view;

+ (CGRect) constrainedFrameForLabel:(UILabel*)label width:(CGFloat)width origin:(CGPoint)origin;

+ (WEPopoverContainerViewProperties *)improvedContainerViewProperties;

@end
