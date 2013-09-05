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
#import "TUSafariActivity.h"
#import "FacebookSDK.h"

@interface OWSocialController()
@property (nonatomic, strong) ACAccount *twitterAccount;
@end

@implementation OWSocialController
@synthesize accountStore, facebookRetryCount, twitterAccount;

- (BOOL) twitterSessionReady {
    return self.twitterAccount != nil;
}

+ (void) shareURL:(NSURL*)url title:(NSString*)title fromViewController:(UIViewController*)viewController {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[title, url] applicationActivities:nil];
    
    [viewController presentViewController:activityViewController animated:YES completion:nil];
}

+ (void) shareMediaObject:(OWMediaObject*)mediaObject fromViewController:(UIViewController*)viewController {
    TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:2];
    if (mediaObject.shareURL) {
        [items addObject:mediaObject.shareURL];
        if (mediaObject.title) {
            [items addObject:mediaObject.title];
        }
        [items addObject:@"via @OpenWatch"];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[safariActivity]];
        
        UIActivityViewControllerCompletionHandler completionHandler = ^(NSString *activityType, BOOL completed) {
            NSLog(@"activity: %@", activityType);
        };
        
        activityViewController.completionHandler = completionHandler;
        
        [viewController presentViewController:activityViewController animated:YES completion:nil];
    }
}

- (void) clearTwitterAccount {
    self.twitterAccount = nil;
    [OWSettingsController sharedInstance].account.twitterAccountIdentifier = nil;
}

- (id) init {
    if (self = [super init]) {
        self.accountStore = [[ACAccountStore alloc] init];
        NSString *identifier = [OWSettingsController sharedInstance].account.twitterAccountIdentifier;
        self.twitterAccount = [accountStore accountWithIdentifier:identifier];
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
    if (!account) {
        callbackBlock(nil, [NSError errorWithDomain:@"net.openwatch.OpenWatch" code:1414 userInfo:@{NSLocalizedDescriptionKey: @"No account found"}]);
        return;
    }
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

- (void) fetchTwitterAccountForViewController:(UIViewController*)viewController callbackBlock:(OWTwitterAccountSelectionCallback)callbackBlock {
    if (self.twitterAccount) {
        callbackBlock(twitterAccount,nil);
        return;
    }
    
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
                     self.twitterAccount = account;
                     [OWSettingsController sharedInstance].account.twitterAccountIdentifier = twitterAccount.identifier;
                     if (callbackBlock) {
                         callbackBlock(account, nil);
                     }
                 } else {
                     OWTwitterAccountViewController *twitterAccountController = [[OWTwitterAccountViewController alloc] initWithAccounts:accounts callbackBlock:^(ACAccount *selectedAccount, NSError *error) {
                         if (selectedAccount) {
                             self.twitterAccount = selectedAccount;
                             [OWSettingsController sharedInstance].account.twitterAccountIdentifier = twitterAccount.identifier;
                         }
                         if (callbackBlock) {
                             callbackBlock(selectedAccount, error);
                         }
                     }];
                     UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:twitterAccountController];
                     [viewController presentViewController:nav
                                        animated:YES completion:nil];
                 }
             }
         });
     }];
}

- (void) updateTwitterStatusFromMediaObject:(OWMediaObject*)mediaObject forAccount:(ACAccount*)account callbackBlock:(void (^)(NSDictionary* responseData, NSError *error))callbackBlock {
    NSString *url = mediaObject.shareURL.absoluteString;
    NSString *description = nil;
    if (mediaObject.title.length > 0) {
        description = mediaObject.title;
    } else {
        description = @"";
    }
    NSString *postFix = @"via @OpenWatch";
    NSString *status = [NSString stringWithFormat:@"%@ %@ %@", url, description, postFix];
    [self updateTwitterStatus:status forAccount:account callbackBlock:callbackBlock];
}

- (void) updateTwitterStatus:(NSString*)status forAccount:(ACAccount*)account callbackBlock:(void (^)(NSDictionary* responseData, NSError *error))callbackBlock {
    NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    
    NSMutableDictionary *parameters =
    [[NSMutableDictionary alloc] init];
    if (status) {
        [parameters setObject:status forKey:@"status"];
    }
    
    SLRequest *postRequest = [SLRequest
                              requestForServiceType:SLServiceTypeTwitter
                              requestMethod:SLRequestMethodPOST
                              URL:requestURL parameters:parameters];
    
    postRequest.account = account;
    
    [postRequest performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse
       *urlResponse, NSError *error) {
         if (callbackBlock) {
             if (error) {
                 callbackBlock(nil, error);
             }
             NSDictionary *data = [NSJSONSerialization
                                   JSONObjectWithData:responseData
                                   options:NSJSONReadingMutableLeaves
                                   error:&error];
             if (error) {
                 callbackBlock(nil, error);
             }
             callbackBlock(data, nil);
         }
     }];
}

- (void) updateFacebookStatusFromMediaObject:(OWMediaObject*)mediaObject callbackBlock:(void (^)(id result, NSError *error))callbackBlock {
    if (![self facebookSessionReady]) {
        [self requestPermissionAndPostMediaObject:mediaObject callbackBlock:callbackBlock];
    } else {
        [self postOpenGraphActionWithMediaObject:mediaObject callbackBlock:callbackBlock];
    }
}

- (BOOL) facebookSessionReady {
    return [FBSession.activeSession.permissions indexOfObject:@"publish_actions"] != NSNotFound;
}


// Helper method to request publish permissions and post.
- (void)requestPermissionAndPostMediaObject:(OWMediaObject*)mediaObject callbackBlock:(void (^)(id result, NSError *error))callbackBlock {
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                          defaultAudience:FBSessionDefaultAudienceFriends
                                        completionHandler:^(FBSession *session, NSError *error) {
                                            if (!error) {
                                                // Now have the permission
                                                [self postOpenGraphActionWithMediaObject:mediaObject callbackBlock:callbackBlock];
                                            } else {
                                                if (callbackBlock) {
                                                    callbackBlock(nil, error);
                                                }
                                                // Facebook SDK * error handling *
                                                // if the operation is not user cancelled
                                                [self handlePostOpenGraphActionError:error mediaObject:mediaObject callbackBlock:callbackBlock];
                                            }
                                        }];
}

- (void)postOpenGraphActionWithMediaObject:(OWMediaObject*)mediaObject callbackBlock:(void (^)(id result, NSError *error))callbackBlock {
    NSError *error = nil;
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *localMediaObject = (OWMediaObject*)[localContext existingObjectWithID:mediaObject.objectID error:&error];
    if (error) {
        callbackBlock(nil, error);
        return;
    }
    
    NSString *url = localMediaObject.shareURL.absoluteString;
    
    NSMutableDictionary<FBGraphObject> *action = [FBGraphObject graphObject];
    action[@"other"] = url;
    action[@"type"] = @"video.other";
    action[@"fb:explicitly_shared"] = @"true";
    
    [FBRequestConnection startForPostWithGraphPath:@"me/openwatch:post_a_video"
                                       graphObject:action
                                 completionHandler:^(FBRequestConnection *connection,
                                                     id result,
                                                     NSError *error) {
                                     if (error) {
                                         if (callbackBlock) {
                                             callbackBlock(nil, error);
                                         }
                                         [self handlePostOpenGraphActionError:error mediaObject:mediaObject callbackBlock:callbackBlock];
                                     } else {
                                         callbackBlock(result, nil);
                                     }
                                 }];
}


- (void)handlePostOpenGraphActionError:(NSError *) error mediaObject:(OWMediaObject*)mediaObject callbackBlock:(void (^)(id result, NSError *error))callbackBlock {
    // Facebook SDK * error handling *
    // Some Graph API errors are retriable. For this sample, we will have a simple
    // retry policy of one additional attempt. Please refer to
    // https://developers.facebook.com/docs/reference/api/errors/ for more information.
    facebookRetryCount++;
    if (error.fberrorCategory == FBErrorCategoryRetry ||
        error.fberrorCategory == FBErrorCategoryThrottling) {
        // We also retry on a throttling error message. A more sophisticated app
        // should consider a back-off period.
        if (facebookRetryCount < 2) {
            NSLog(@"Retrying open graph post");
            [self postOpenGraphActionWithMediaObject:mediaObject callbackBlock:callbackBlock];
            return;
        } else {
            NSLog(@"Retry count exceeded.");
        }
    }
    
    // Facebook SDK * pro-tip *
    // Users can revoke post permissions on your app externally so it
    // can be worthwhile to request for permissions again at the point
    // that they are needed. This sample assumes a simple policy
    // of re-requesting permissions.
    if (error.fberrorCategory == FBErrorCategoryPermissions) {
        NSLog(@"Re-requesting permissions");
        [self requestPermissionAndPostMediaObject:mediaObject callbackBlock:callbackBlock];
        return;
    }
    
    // Facebook SDK * error handling *
    [self presentAlertForError:error];
}

- (void) presentAlertForError:(NSError *)error {
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // When fberrorShouldNotifyUser is YES, a fberrorUserMessage can be
    // presented as a user-ready message
    if (error.fberrorShouldNotifyUser) {
        // The SDK has a message for the user, surface it.
        [[[UIAlertView alloc] initWithTitle:FACEBOOK_ERROR_STRING
                                    message:error.fberrorUserMessage
                                   delegate:nil
                          cancelButtonTitle:OK_STRING
                          otherButtonTitles:nil] show];
    } else {
        NSLog(@"unexpected facebook error:%@", error);
    }
}

- (void) requestFacebookPermisisonsWithCallback:(void (^)(BOOL success, NSError *error))callbackBlock {
    [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (error) {
            if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                [self presentAlertForError:error];
            }
            if (callbackBlock) {
                callbackBlock(NO, error);
            }
        } else {
            if (callbackBlock) {
                callbackBlock(YES, nil);
            }
        }
    }];
}


@end
