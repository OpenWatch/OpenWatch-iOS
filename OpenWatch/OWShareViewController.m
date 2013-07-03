//
//  OWShareViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/14/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWShareViewController.h"
#import "OWShareController.h"
#import "OWUtilities.h"
#import "OWAccountAPIClient.h"
#import "OWLocalMediaController.h"
#import "MBProgressHUD.h"
#import "OWStrings.h"
#import "FacebookSDK.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface OWShareViewController ()

@end

@implementation OWShareViewController
@synthesize titleLabel, urlLabel, previewView, mediaObject, shareButton, skipButton, descriptionLabel, retryCount;

- (id)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [OWUtilities stoneBackgroundPattern];
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = ITS_ONLINE_STRING;
        self.urlLabel = [[UILabel alloc] init];
        self.urlLabel.text = GENERATING_URL_STRING;
        
        self.descriptionLabel = [[UILabel alloc] init];
        self.descriptionLabel.text = CALL_TO_ACTION_SHARE_STRING;
        self.descriptionLabel.numberOfLines = 0;
        self.previewView = [[OWPreviewView alloc] initWithFrame:CGRectZero];
        self.previewView.moviePlayer.shouldAutoplay = YES;
        
        [OWUtilities styleLabel:titleLabel];
        [OWUtilities styleLabel:urlLabel];
        [OWUtilities styleLabel:descriptionLabel];
        
        self.titleLabel.font = [UIFont boldSystemFontOfSize:21.0f];
        self.urlLabel.font = [UIFont systemFontOfSize:16.0f];
        self.descriptionLabel.font = [UIFont systemFontOfSize:13.0f];
        self.urlLabel.adjustsFontSizeToFitWidth = YES;
        
        self.shareButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeSuccess icon:nil fontSize:22.0f];
        [self.shareButton setTitle:SHARE_STRING forState:UIControlStateNormal];
        [self.shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.shareButton addAwesomeIcon:FAIconShare beforeTitle:YES];
        self.title = SHARE_STRING;
        self.shareButton.enabled = NO;
        
        [self.navigationItem setHidesBackButton:YES animated:NO];
        
        self.skipButton = [[UIBarButtonItem alloc] initWithTitle:FINISH_STRING style:UIBarButtonItemStyleBordered target:self action:@selector(skipButtonPressed:)];
        self.navigationItem.rightBarButtonItem = skipButton;
        
        [self.view addSubview:shareButton];
        [self.view addSubview:descriptionLabel];
        [self.view addSubview:urlLabel];
        [self.view addSubview:titleLabel];
        [self.view addSubview:previewView];
        
        self.retryCount = 0;
    }
    return self;
}

- (void) shareButtonPressed:(id)sender {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType
                                     options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted) {
             NSArray *accounts = [accountStore accountsWithAccountType:accountType];
             ACAccount *account = nil;
             for (ACAccount *tempAccount in accounts) {
                 if ([tempAccount.username isEqualToString:@"chrisballingr"]) {
                     account = tempAccount;
                 }
             }
             if (account) {                 
                 NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
                 
                 NSMutableDictionary *parameters =
                 [[NSMutableDictionary alloc] init];
                 NSString *url = mediaObject.shareURL.absoluteString;
                 NSString *description = nil;
                 if (mediaObject.title.length > 0) {
                     description = mediaObject.title;
                 } else {
                     description = @"";
                 }
                 NSString *postFix = @"via @OpenWatch";
                 NSString *status = [NSString stringWithFormat:@"%@ %@ %@", url, description, postFix];
                 if (url) {
                     [parameters setObject:status forKey:@"status"];
                 }
                                  
                 SLRequest *postRequest = [SLRequest
                                           requestForServiceType:SLServiceTypeTwitter
                                           requestMethod:SLRequestMethodPOST
                                           URL:requestURL parameters:parameters];
                 
                 postRequest.account = account;
                 
                 [postRequest performRequestWithHandler:
                  ^(NSData *responseData, NSHTTPURLResponse
                    *urlResponse, NSError *error)
                  {
                      if (error) {
                          NSLog(@"Error making tweet: %@", error.userInfo);
                      }
                      NSDictionary *data = [NSJSONSerialization
                                         JSONObjectWithData:responseData
                                         options:NSJSONReadingMutableLeaves
                                         error:&error];
                      NSLog(@"new data: %@", data);
                  }];
             }
         }
     }];
    
    if (!FBSession.activeSession.isOpen) {
        [FBSession openActiveSessionWithAllowLoginUI: YES];
    }
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        [self requestPermissionAndPost];
    } else {
        [self postOpenGraphAction];
    }
        
    //[OWShareController shareMediaObject:self.mediaObject fromViewController:self];
}

- (void) skipButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) setMediaObject:(OWLocalMediaObject *)newMediaObject {
    mediaObject = newMediaObject;
    
    if (mediaObject.shareURL) {
        self.shareButton.enabled = YES;
        self.urlLabel.text = mediaObject.shareURL.absoluteString;
    } else {
        self.shareButton.enabled = NO;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[OWAccountAPIClient sharedClient] getObjectWithUUID:mediaObject.uuid objectClass:[mediaObject class] success:^(NSManagedObjectID *objectID) {
            OWLocalMediaObject *newObject = [OWLocalMediaController localMediaObjectForObjectID:objectID];
            self.urlLabel.text = newObject.shareURL.absoluteString;
            self.shareButton.enabled = YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(NSString *reason) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } retryCount:kOWAccountAPIClientDefaultRetryCount];
    }
    
    self.previewView.objectID = mediaObject.objectID;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat padding = 10.0f;
    CGFloat buttonHeight = 50.0f;

    CGFloat itemWidth = self.view.frame.size.width - padding * 2;
    CGFloat previewHeight = [OWPreviewView heightForWidth:itemWidth];

    self.titleLabel.frame = CGRectMake(padding, padding, itemWidth, 21);
    
    self.previewView.frame = CGRectMake(padding, [OWUtilities bottomOfView:titleLabel] + padding, itemWidth, previewHeight);
    self.urlLabel.frame = CGRectMake(padding, [OWUtilities bottomOfView:previewView] + padding, itemWidth, 20);
    self.shareButton.frame = CGRectMake(padding, [OWUtilities bottomOfView:urlLabel] + padding, itemWidth, buttonHeight);

    self.descriptionLabel.frame = CGRectMake(padding, [OWUtilities bottomOfView:shareButton] + padding, itemWidth, 40);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Helper method to request publish permissions and post.
- (void)requestPermissionAndPost {
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                          defaultAudience:FBSessionDefaultAudienceFriends
                                        completionHandler:^(FBSession *session, NSError *error) {
                                            if (!error) {
                                                // Now have the permission
                                                [self postOpenGraphAction];
                                            } else {
                                                // Facebook SDK * error handling *
                                                // if the operation is not user cancelled
                                                if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                    [self presentAlertForError:error];
                                                }
                                            }
                                        }];
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
        NSLog(@"unexpected error:%@", error);
    }
}

- (void)postOpenGraphAction {
    NSString *url = mediaObject.shareURL.absoluteString;
    
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
                                         [self handlePostOpenGraphActionError:error];
                                     }
                                 }];
}

- (void)handlePostOpenGraphActionError:(NSError *) error{
    // Facebook SDK * error handling *
    // Some Graph API errors are retriable. For this sample, we will have a simple
    // retry policy of one additional attempt. Please refer to
    // https://developers.facebook.com/docs/reference/api/errors/ for more information.
    retryCount++;
    if (error.fberrorCategory == FBErrorCategoryRetry ||
        error.fberrorCategory == FBErrorCategoryThrottling) {
        // We also retry on a throttling error message. A more sophisticated app
        // should consider a back-off period.
        if (retryCount < 2) {
            NSLog(@"Retrying open graph post");
            [self postOpenGraphAction];
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
        [self requestPermissionAndPost];
        return;
    }
    
    // Facebook SDK * error handling *
    [self presentAlertForError:error];
}

@end
