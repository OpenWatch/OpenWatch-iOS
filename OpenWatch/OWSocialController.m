//
//  OWSocialController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/5/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWSocialController.h"
#import "OWStrings.h"
#import "OWSettingsController.h"
#import "OWAccountAPIClient.h"

@implementation OWSocialController
@synthesize accountStore;

- (id) init {
    if (self = [super init]) {
        self.accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}

+ (OWSocialController *)sharedInstance {
    static OWSocialController *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[OWSocialController alloc] init];
    });
    return _sharedClient;
}

- (void) profileForTwitterAccount:(ACAccount*)account callbackBlock:(void (^)(NSDictionary *profile, NSError *error))callbackBlock {
    NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
    
    SLRequest *getRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestURL parameters:@{@"screen_name": account.username}];
    getRequest.account = account;
    
    [getRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (callbackBlock) {
                callbackBlock(nil, error);
            }
        }
        NSDictionary *data = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:&error];
        if (error) {
            if (callbackBlock) {
                callbackBlock(nil, error);
            }
        } else {
            if (callbackBlock) {
                callbackBlock(data, nil);
            }
        }
    }];
}


- (void) linkTwitterAccountFromViewController:(UIViewController*)viewController callbackBlock:(OWTwitterAccountSelectionCallback)callbackBlock {
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType
                                          options:nil completion:^(BOOL granted, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (error) {
                 NSString *message;
                 if (error.code == 6) {
                     message = NO_TWITTER_ACCOUNTS_ERROR_STRING;
                 } else if (error.code == 7) {
                     message = ERROR_LINKING_TWITTER_MESSAGE_STRING;
                 } else {
                     message = error.localizedDescription;
                 }
                 NSLog(@"Error linking account: %@", error.userInfo);
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_LINKING_ACCOUNT_STRING message:message delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles:nil];
                 [alert show];
                 return;
             }
             if (granted) {
                 NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                 ACAccount *account = nil;
                 if (accounts.count == 1) {
                     account = [accounts objectAtIndex:0];
                     if (callbackBlock) {
                         callbackBlock(account, nil);
                     }
                 } else {
                     OWTwitterAccountViewController *twitterAccountController = [[OWTwitterAccountViewController alloc] initWithAccounts:accounts callbackBlock:callbackBlock];
                     UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:twitterAccountController];
                     [viewController presentViewController:nav
                                        animated:YES completion:nil];
                 }
             }
         });
     }];
}

@end
