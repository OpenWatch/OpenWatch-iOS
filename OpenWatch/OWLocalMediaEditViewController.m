//
//  OWLocalMediaEditViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/17/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWLocalMediaEditViewController.h"
#import "OWStrings.h"
#import "OWCaptureAPIClient.h"
#import "OWAccountAPIClient.h"
#import "OWMapAnnotation.h"
#import "OWRecordingController.h"
#import "OWUtilities.h"
#import "OWAppDelegate.h"
#import "OWTag.h"
#import "MBProgressHUD.h"
#import "OWSettingsController.h"
#import "OWLocalMediaController.h"
#import "OWPhoto.h"
#import "OWSocialController.h"
#import "OWSocialTableItem.h"
#import "OWEditableMediaCell.h"
#import "FacebookSDK.h"

#define TAGS_ROW 0
#define PADDING 10.0f

static NSString *cellIdentifier = @"CellIdentifier";
static NSString *editableCellIdentifier = @"EditableCellIdentifier";


@interface OWLocalMediaEditViewController ()

@end

@implementation OWLocalMediaEditViewController
@synthesize titleTextView, doneButton, objectID, showingAfterCapture, primaryTag, keyboardControls, socialTableView, facebookSwitch, twitterSwitch, openwatchSwitch, previewView, twitterAccount, facebookRetryCount;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setupSocialSwitches {
    self.facebookSwitch = [[UISwitch alloc] init];
    [self.facebookSwitch addTarget:self action:@selector(toggleFacebookSwitch:) forControlEvents:UIControlEventValueChanged];
    OWSocialTableItem *facebookItem = [[OWSocialTableItem alloc] initWithSwitch:facebookSwitch image:[UIImage imageNamed:@"208-facebook.png"] text:POST_TO_FACEBOOK_STRING];
    
    self.twitterSwitch = [[UISwitch alloc] init];
    [self.twitterSwitch addTarget:self action:@selector(toggleTwitterSwitch:) forControlEvents:UIControlEventValueChanged];
    OWSocialTableItem *twitterItem = [[OWSocialTableItem alloc] initWithSwitch:twitterSwitch image:[UIImage imageNamed:@"210-twitterbird.png"] text:POST_TO_TWITTER_STRING];

    self.openwatchSwitch = [[UISwitch alloc] init];
    OWSocialTableItem *openWatchItem = [[OWSocialTableItem alloc] initWithSwitch:openwatchSwitch image:nil text:POST_TO_OPENWATCH_STRING];
    
    self.socialItems = @[openWatchItem, facebookItem, twitterItem];
}

- (void) toggleFacebookSwitch:(id)sender {
    if (self.facebookSwitch.on && !FBSession.activeSession.isOpen) {
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                    [self presentAlertForError:error];
                }
                NSLog(@"Error opening Facebook session: %@", error.userInfo);
                [self.facebookSwitch setOn:NO animated:YES];
            } else {
                NSLog(@"Facebook session opened successfully: %@", session.description);
            }
        }];
    }
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
                                                [self handlePostOpenGraphActionError:error];
                                            }
                                        }];
}

- (void)postOpenGraphAction {
    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:objectID];
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
                                     } else {
                                         NSLog(@"Successfully posted Facebook update: %@", result);
                                     }
                                 }];
}


- (void)handlePostOpenGraphActionError:(NSError *) error{
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

- (void) attemptFacebookPost {
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        [self requestPermissionAndPost];
    } else {
        [self postOpenGraphAction];
    }
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

- (void) toggleTwitterSwitch:(id)sender {
    if (self.twitterSwitch.on && !self.twitterAccount) {
        [[OWSocialController sharedInstance] fetchTwitterAccountForViewController:self callbackBlock:^(ACAccount *selectedAccount, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [self.twitterSwitch setOn:NO animated:YES];
                } else {
                    self.twitterAccount = selectedAccount;
                    NSLog(@"Twitter account selected: %@", selectedAccount);
                }
            });
        }];
    }
}

- (void) setupSocialTable {
    self.socialTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.socialTableView.allowsSelection = NO;
    self.socialTableView.dataSource = self;
    self.socialTableView.delegate = self;
    self.socialTableView.backgroundColor = [UIColor clearColor];
    self.socialTableView.backgroundView = nil;
    [self.socialTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.socialTableView registerClass:[OWEditableMediaCell class] forCellReuseIdentifier:editableCellIdentifier];
    [self.view addSubview:socialTableView];
}

- (id) init {
    if (self = [super init]) {
        self.view.backgroundColor = [OWUtilities stoneBackgroundPattern];
        self.title = EDIT_STRING;
        [self setupFields];
        [self setupSocialSwitches];
        [self setupSocialTable];
        
        self.keyboardControls = [[BSKeyboardControls alloc] initWithFields:@[titleTextView]];
        self.keyboardControls.delegate = self;
        
        self.doneButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeSuccess];
        [self.doneButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.doneButton setTitle:DONE_STRING forState:UIControlStateNormal];
    
        self.showingAfterCapture = NO;
    }
    return self;
}

- (void) setObjectID:(NSManagedObjectID *)newObjectID {
    objectID = newObjectID;

    [self refreshFields];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.socialTableView.frame = self.view.bounds;
    [TestFlight passCheckpoint:EDIT_METADATA_CHECKPOINT];
    [self checkRecording];
    [titleTextView becomeFirstResponder];
    if (showingAfterCapture) {
        [self.navigationItem setHidesBackButton:YES];
    }
}


- (void) refreshFields {
    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:objectID];
    NSString *title = mediaObject.title;
    if (title) {
        self.titleTextView.text = title;
    } else {
        self.titleTextView.text = @"";
    }
    self.previewView.objectID = objectID;
}

- (void) setPrimaryTag:(NSString *)newPrimaryTag {
    primaryTag = newPrimaryTag;
}


-(void)setupFields {
    self.titleTextView = [[SSTextView alloc] init];
    self.titleTextView.delegate = self;
    self.titleTextView.keyboardType = UIKeyboardTypeTwitter;
    self.titleTextView.placeholder = WHAT_HAPPENED_LABEL_STRING;
    self.titleTextView.backgroundColor = [UIColor clearColor];
    self.titleTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
    
    self.previewView = [[OWPreviewView alloc] init];
}

- (void) saveButtonPressed:(id)sender {
    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:self.objectID];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSMutableString *finalTitleString = [[NSMutableString alloc] init];
    NSString *initialTitleString = self.titleTextView.text;
    int tagLength = primaryTag.length;
    
    // define the range you're interested in
    NSRange stringRange = {0, MIN([initialTitleString length], 254-tagLength)};
    
    // adjust the range to include dependent chars
    stringRange = [initialTitleString rangeOfComposedCharacterSequencesForRange:stringRange];
    
    // Now you can create the short string
    NSString *shortString = [initialTitleString substringWithRange:stringRange];
    [finalTitleString appendString:shortString];
    if (primaryTag) {
        [finalTitleString appendFormat:@" #%@", primaryTag];
    }
    
    NSString *trimmedText = [finalTitleString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    mediaObject.title = trimmedText;
    [context MR_saveToPersistentStoreAndWait];    
        
    [[OWAccountAPIClient sharedClient] postObjectWithUUID:mediaObject.uuid objectClass:[mediaObject class] success:^{
        if (self.twitterSwitch.on && self.twitterAccount) {
            [[OWSocialController sharedInstance] updateTwitterStatusFromMediaObject:mediaObject forAccount:twitterAccount callbackBlock:^(NSDictionary *responseData, NSError *error) {
                if (error) {
                    NSLog(@"Error updating Twitter status: %@", error.userInfo);
                } else {
                    NSLog(@"Twitter status updated: %@", responseData);
                }
            }];
        }
        if (self.facebookSwitch.on) {
            [self attemptFacebookPost];
        }
    } failure:nil retryCount:kOWAccountAPIClientDefaultRetryCount];
    
    [self.view endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) checkRecording {
    if (showingAfterCapture) {
        [self refreshFields];
        return;
    }
    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:self.objectID];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[OWAccountAPIClient sharedClient] getObjectWithUUID:mediaObject.uuid objectClass:mediaObject.class success:^(NSManagedObjectID *objectID) {
        [self refreshFields];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSString *reason) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } retryCount:kOWAccountAPIClientDefaultRetryCount];
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    [self.keyboardControls setActiveField:textView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyControls
{
    [keyControls.activeField resignFirstResponder];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.socialItems.count;
    } else if (section == 2) {
        return 1;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [OWEditableMediaCell cellHeight];
    } else {
        return 45.0f;
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:editableCellIdentifier forIndexPath:indexPath];
        OWEditableMediaCell *editableCell = (OWEditableMediaCell*)cell;
        editableCell.textView = titleTextView;
        editableCell.previewView = previewView;
    } else if (indexPath.section == 1) {
        OWSocialTableItem *socialItem = [self.socialItems objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = socialItem.text;
        cell.imageView.image = socialItem.image;
        cell.accessoryView = socialItem.socialSwitch;
    } else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        [cell.contentView addSubview:doneButton];
        self.doneButton.frame = cell.contentView.bounds;
    }
    return cell;
}

@end
