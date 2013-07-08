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
#import "OWTwitterAccountViewController.h"

@interface OWSocialController : NSObject

@property (nonatomic, strong) ACAccountStore *accountStore;

+ (OWSocialController *)sharedInstance;

- (void) profileForTwitterAccount:(ACAccount*)account callbackBlock:(void (^)(NSDictionary *profile, NSError *error))callbackBlock;

- (void) fetchTwitterAccountForViewController:(UIViewController*)viewController callbackBlock:(OWTwitterAccountSelectionCallback)callbackBlock;

@end
