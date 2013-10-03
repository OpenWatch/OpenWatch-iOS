//
//  OWFontManager.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 10/3/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWFontManager.h"

@implementation OWFontManager
@synthesize defaultFontFamily;

- (id) initWithDefaultFontFamily:(NSString *)fontFamily {
    if (self = [super init]) {
        self.defaultFontFamily = fontFamily;
    }
    return self;
}

- (UIFont*) fontWithFamily:(NSString *)fontFamily weight:(NSString *)weight size:(CGFloat)size {
    NSString *fontName = nil;
    if (weight.length) {
        fontName = [NSString stringWithFormat:@"%@-%@", fontFamily, weight];
    } else {
        fontName = fontFamily;
    }
    UIFont *font = [UIFont fontWithName:fontName size:size];
    if (!font) {
        font = [UIFont systemFontOfSize:size];
    }
    return font;
}

- (UIFont*) fontWithWeight:(NSString*)weight size:(CGFloat)size {
    return [self fontWithFamily:defaultFontFamily weight:weight size:size];
}
- (UIFont*) fontWithSize:(CGFloat)size {
    return [self fontWithWeight:@"" size:size];
}
- (UIFont*) boldFontWithSize:(CGFloat)size {
    return [self fontWithWeight:@"Bold" size:size];
}


@end
