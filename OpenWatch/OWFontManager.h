//
//  OWFontManager.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 10/3/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWFontManager : NSObject

@property (nonatomic, strong) NSString *defaultFontFamily;

- (UIFont*) fontWithFamily:(NSString*)fontFamily weight:(NSString*)weight size:(CGFloat)size;
- (UIFont*) fontWithWeight:(NSString*)weight size:(CGFloat)size;
- (UIFont*) fontWithSize:(CGFloat)size;
- (UIFont*) boldFontWithSize:(CGFloat)size;

- (id) initWithDefaultFontFamily:(NSString*)fontFamily;

@end
