//
//  OWSocialController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/5/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface OWSocialController : NSObject

+ (void) profileForTwitterAccount:(ACAccount*)account callbackBlock:(void (^)(NSDictionary *profile, NSError *error))callbackBlock;

@end
