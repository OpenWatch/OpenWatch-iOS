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

@class OWMediaObject;

@interface OWSocialController : NSObject

@property (nonatomic, strong) ACAccountStore *accountStore;

+ (OWSocialController *)sharedInstance;

+ (void) shareMediaObject:(OWMediaObject*)mediaObject fromViewController:(UIViewController*)viewController;
+ (void) shareURL:(NSURL*)url title:(NSString*)title fromViewController:(UIViewController*)viewController;

- (void) profileForTwitterAccount:(ACAccount*)account callbackBlock:(void (^)(NSDictionary *profile, NSError *error))callbackBlock;

- (void) fetchTwitterAccountForViewController:(UIViewController*)viewController callbackBlock:(OWTwitterAccountSelectionCallback)callbackBlock;
- (void) updateTwitterStatus:(NSString*)status forAccount:(ACAccount*)account callbackBlock:(void (^)(NSDictionary* responseData, NSError *error))callbackBlock;
- (void) updateTwitterStatusFromMediaObject:(OWMediaObject*)mediaObject forAccount:(ACAccount*)account callbackBlock:(void (^)(NSDictionary* responseData, NSError *error))callbackBlock;


@end
