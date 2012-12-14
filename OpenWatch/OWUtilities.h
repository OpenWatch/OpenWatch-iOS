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
+ (UIColor*) greyColorWithGreyness:(CGFloat)greyness;

+ (NSDateFormatter*) utcDateFormatter;
+ (NSDateFormatter*) localDateFormatter;
+ (NSString*) baseURLString;

+ (WEPopoverContainerViewProperties *)improvedContainerViewProperties;

@end
