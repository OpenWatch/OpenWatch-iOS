//
//  OWUtilities.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/29/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWUtilities.h"

@implementation OWUtilities

+ (UIColor*) fabricBackgroundPattern {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"fabric.jpeg"]];
}

+ (NSDateFormatter*) dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    return dateFormatter;
}

+ (NSString*) baseURLString {
    return @"http://192.168.1.44:8000/";
}

@end
