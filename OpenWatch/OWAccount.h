//
//  OWAccount.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWUser.h"
#import <Accounts/Accounts.h>

@interface OWAccount : NSObject

@property (nonatomic, strong) ACAccountStore *accountStore;

@property (nonatomic, strong) NSNumber *accountID;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *publicUploadToken;
@property (nonatomic, strong) NSString *privateUploadToken;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) ACAccount* twitterAccount;
@property (nonatomic) BOOL secretAgentEnabled;
@property (nonatomic) BOOL hasCompletedOnboarding;
@property (nonatomic) BOOL missionsDescriptionDismissed;

- (OWUser*) user;

- (void) clearAccountData;
- (BOOL) isLoggedIn;


@end
