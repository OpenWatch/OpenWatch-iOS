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
+ (NSDateFormatter*) dateFormatter;
+ (NSString*) baseURLString;

+ (WEPopoverContainerViewProperties *)improvedContainerViewProperties;

@end
