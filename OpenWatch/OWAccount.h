//
//  OWAccount.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWUser.h"

@interface OWAccount : NSObject

@property (nonatomic, strong) NSNumber *accountID;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *publicUploadToken;
@property (nonatomic, strong) NSString *privateUploadToken;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *username;
@property (nonatomic) BOOL hasCompletedOnboarding;

- (OWUser*) user;

- (void) clearAccountData;
- (BOOL) isLoggedIn;

@end
