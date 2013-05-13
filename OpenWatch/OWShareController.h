//
//  OWShareController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/13/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWMediaObject.h"

@interface OWShareController : NSObject

+ (void) shareMediaObject:(OWMediaObject*)mediaObject fromViewController:(UIViewController*)viewController;

@end
