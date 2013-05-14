//
//  OWStyleSheet.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/14/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWStyleSheet.h"
#import "OWUtilities.h"

@implementation OWStyleSheet

- (UIColor*) backgroundColor {
    return [OWUtilities stoneBackgroundPattern];
}

- (UIImage*) navigationBarBackgroundImage {
    return [OWUtilities navigationBarBackgroundImage];
}

- (UIColor*) navigationBarTintColor {
    return [OWUtilities navigationBarColor];
}


@end
