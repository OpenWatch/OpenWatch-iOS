//
//  OWProfileViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/30/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWProfileViewController.h"
#import "OWUtilities.h"
#import "OWSettingsController.h"
#import <QuartzCore/QuartzCore.h>
#import "OWAccountAPIClient.h"
#import "OWStrings.h"
#import "AFNetworking.h"
#import "OWSocialController.h"

#define USER_PHOTO_ACTIONSHEET_TAG 1
#define TWITTER_DISCONNECT_ACTIONSHEET_TAG 2

@interface OWProfileViewController ()

@end

@implementation OWProfileViewController
@synthesize userView, firstNameField, lastNameField, aboutMeTextView, user, choosePhotoButton, scrollView, keyboardControls, imagePicker;
@synthesize updatedProfilePhoto, facebookLoginView, facebookID, linkTwitterButton;
@synthesize firstNameLabel, lastNameLabel, aboutMeLabel, connectAccountsLabel;

- (id)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [OWUtilities stoneBackgroundPattern];
        self.scrollView = [[UIScrollView alloc] init];
        [self.view addSubview:scrollView];
        
        self.userView = [[OWUserProfileView alloc] initWithFrame:CGRectZero];
        UIFont *editableFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
        self.firstNameField = [[SLGlowingTextField alloc] init];
        self.firstNameField.delegate = self;
        self.firstNameField.placeholder = FIRST_NAME_STRING;
        self.firstNameField.font = editableFont;
        self.firstNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.lastNameField = [[SLGlowingTextField alloc] init];
        self.lastNameField.placeholder = LAST_NAME_STRING;
        self.lastNameField.delegate = self;
        self.lastNameField.font = editableFont;
        self.lastNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.aboutMeTextView = [[SSTextView alloc] init];
        self.aboutMeTextView.backgroundColor = [UIColor clearColor];
        self.aboutMeTextView.editable = YES;
        self.aboutMeTextView.delegate = self;
        self.aboutMeTextView.font = editableFont;
        self.aboutMeTextView.placeholder = TELL_US_ABOUT_YOURSELF_STRING;
        self.aboutMeTextView.placeholderTextColor = [OWUtilities greyColorWithGreyness:0.5];
        self.title = EDIT_PROFILE_STRING;
        
        self.firstNameLabel = [[UILabel alloc] init];
        self.firstNameLabel.text = FIRST_NAME_STRING;
        self.lastNameLabel = [[UILabel alloc] init];
        self.lastNameLabel.text = LAST_NAME_STRING;
        self.aboutMeLabel = [[UILabel alloc] init];
        self.aboutMeLabel.text = ABOUT_YOURSELF_STRING;
        self.connectAccountsLabel = [[UILabel alloc] init];
        self.connectAccountsLabel.text = LINK_SOCIAL_MEDIA_ACCOUNTS_STRING;
        
        NSArray *labels = @[firstNameLabel, lastNameLabel, aboutMeLabel, connectAccountsLabel];
        
        for (UILabel *label in labels) {
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10.0f];
            label.textColor = [UIColor lightGrayColor];
            [self.scrollView addSubview:label];
        }
        
        NSArray *fields = @[firstNameField, lastNameField, aboutMeTextView];
        
        self.keyboardControls = [[BSKeyboardControls alloc] initWithFields:fields];
        self.keyboardControls.delegate = self;
        
        self.choosePhotoButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [self.choosePhotoButton addTarget:self action:@selector(choosePhotoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:SAVE_STRING style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
        doneButton.tintColor = [OWUtilities doneButtonColor];
        self.navigationItem.rightBarButtonItem = doneButton;
        
        self.facebookLoginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info"]];
        self.linkTwitterButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeTwitter icon:nil fontSize:17.0f];
        ACAccount *twitterAccount = [OWSocialController sharedInstance].twitterAccount;
        if (twitterAccount) {
            [linkTwitterButton setTitle:CONNECTED_STRING forState:UIControlStateNormal];
        } else {
            [linkTwitterButton setTitle:CONNECT_STRING forState:UIControlStateNormal];
        }
        [linkTwitterButton addAwesomeIcon:FAIconTwitter beforeTitle:YES];
        
        [linkTwitterButton addTarget:self action:@selector(linkTwitterPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        self.facebookLoginView.delegate = self;
        
        [self.scrollView addSubview:userView];
        [self.scrollView addSubview:firstNameField];
        [self.scrollView addSubview:lastNameField];
        [self.scrollView addSubview:aboutMeTextView];
        [self.scrollView addSubview:choosePhotoButton];
        [self.scrollView addSubview:facebookLoginView];
        [self.scrollView addSubview:linkTwitterButton];
    }
    return self;
}

- (void) linkTwitterPressed:(id)sender {
    ACAccount *existingAccount = [OWSocialController sharedInstance].twitterAccount;
    
    if (existingAccount) {
        NSString *title = [NSString stringWithFormat:LOGGED_IN_AS_STRING, existingAccount.username];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:CANCEL_STRING destructiveButtonTitle:LOGOUT_STRING otherButtonTitles:nil];
        actionSheet.tag = TWITTER_DISCONNECT_ACTIONSHEET_TAG;
        [actionSheet showInView:self.view];
        return;
    }
    
    __weak __typeof(&*self)weakSelf = self;
    [[OWSocialController sharedInstance] fetchTwitterAccountForViewController:self callbackBlock:^(ACAccount *selectedAccount, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{            
            NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
            [[OWSettingsController sharedInstance] account].user.twitter = selectedAccount.username;
            [context MR_saveToPersistentStoreAndWait];
            [[OWAccountAPIClient sharedClient] updateUserTwitterAccount];
            
            if (weakSelf.aboutMeTextView.text.length == 0) {
                weakSelf.aboutMeTextView.placeholder = LOADING_FROM_TWITTER_STRING;
                
                [[OWSocialController sharedInstance] profileForTwitterAccount:selectedAccount callbackBlock:^(NSDictionary *profile, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) {
                            NSLog(@"Error fetching profile: %@", error.userInfo);
                            weakSelf.aboutMeTextView.placeholder = TELL_US_ABOUT_YOURSELF_STRING;
                        } else {
                            weakSelf.aboutMeTextView.text = [profile objectForKey:@"description"];
                        }
                    });
                }];
            }
            
            [weakSelf.linkTwitterButton setTitle:CONNECTED_STRING forState:UIControlStateNormal];
            [weakSelf.linkTwitterButton addAwesomeIcon:FAIconTwitter beforeTitle:YES];
        });
    }];
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


- (void) saveButtonPressed:(id)sender {
    self.user.firstName = self.firstNameField.text;
    self.user.lastName = self.lastNameField.text;
    self.user.bio = self.aboutMeTextView.text;
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreAndWait];
    
    [[OWAccountAPIClient sharedClient] updateUserPhoto:self.updatedProfilePhoto];
    [[OWAccountAPIClient sharedClient] updateUserProfile];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    CGFloat padding = 10.0f;
    CGFloat frameWidth = self.view.frame.size.width;
    CGFloat paddedWidth = frameWidth - padding * 2;
    
    CGFloat userViewSize = 100.0f;
    self.userView.frame = CGRectMake(padding, padding, userViewSize, userViewSize);
    CGFloat choosePhotoSize = 30.0f;
    CGFloat buttonInset = 15.0f;
    self.choosePhotoButton.frame = CGRectMake(0, 0, choosePhotoSize, choosePhotoSize);
    self.choosePhotoButton.center = CGPointMake(self.userView.frame.origin.x + self.userView.frame.size.width - buttonInset, self.userView.frame.origin.y + self.userView.frame.size.height - buttonInset);
    CGFloat fieldHeight = 30.0f;
    CGFloat fieldXOrigin = [OWUtilities rightOfView:userView] + padding;
    CGFloat fieldWidth = frameWidth - fieldXOrigin - padding;
    CGFloat labelHeight = 13.0f;
    self.firstNameLabel.frame = CGRectMake(fieldXOrigin, padding, fieldWidth, labelHeight);
    self.firstNameField.frame = CGRectMake(fieldXOrigin, [OWUtilities bottomOfView:firstNameLabel], fieldWidth, fieldHeight);
    self.lastNameLabel.frame = CGRectMake(fieldXOrigin, [OWUtilities bottomOfView:firstNameField] + padding, fieldWidth, labelHeight);
    self.lastNameField.frame = CGRectMake(fieldXOrigin, [OWUtilities bottomOfView:lastNameLabel], fieldWidth, fieldHeight);
    self.aboutMeLabel.frame = CGRectMake(padding, [OWUtilities bottomOfView:userView] + padding, paddedWidth, labelHeight);
    self.aboutMeTextView.frame = CGRectMake(padding, [OWUtilities bottomOfView:aboutMeLabel] + padding, paddedWidth, 90.0f);
    self.connectAccountsLabel.frame = CGRectMake(padding, [OWUtilities bottomOfView:aboutMeTextView] + padding, paddedWidth, labelHeight);
    CGFloat socialButtonYOrigin = [OWUtilities bottomOfView:connectAccountsLabel] + padding;
    CGFloat socialButtonWidth = (paddedWidth / 2) - (padding / 2);
    CGFloat socialButtonHeight = 45.0f;
    self.facebookLoginView.frame = CGRectMake(padding, socialButtonYOrigin, socialButtonWidth, 45);
    self.linkTwitterButton.frame = CGRectMake([OWUtilities rightOfView:facebookLoginView] + padding, socialButtonYOrigin, socialButtonWidth, socialButtonHeight);
    self.scrollView.contentSize = CGSizeMake(paddedWidth, [OWUtilities bottomOfView:facebookLoginView] + padding);
}

- (void) setUser:(OWUser *)newUser {
    user = newUser;
    UITextBorderStyle borderStyle = UITextBorderStyleNone;
    self.firstNameField.borderStyle = borderStyle;
    self.lastNameField.borderStyle = borderStyle;
    
    self.firstNameField.text = user.firstName;
    self.lastNameField.text = user.lastName;
    self.aboutMeTextView.text = user.bio;
    
    self.userView.user = user;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyControls
{
    [keyControls.activeField resignFirstResponder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    self.keyboardControls.activeField = textField;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (void) choosePhotoButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:CHOOSE_PHOTO_STRING delegate:self cancelButtonTitle:CANCEL_STRING destructiveButtonTitle:nil otherButtonTitles:TAKE_PICTURE_STRING, CHOOSE_FROM_CAMERA_ROLL_STRING, nil];
    [actionSheet showInView:self.view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    if (actionSheet.tag == USER_PHOTO_ACTIONSHEET_TAG) {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if (!self.imagePicker) {
            self.imagePicker = [[UIImagePickerController alloc] init];
            self.imagePicker.delegate = self;
        }
        if (buttonIndex == 1) {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
        if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
            self.imagePicker.sourceType = sourceType;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    } else if (actionSheet.tag == TWITTER_DISCONNECT_ACTIONSHEET_TAG) {
        [[OWSocialController sharedInstance] clearTwitterAccount];
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        user.twitter = nil;
        [context MR_saveToPersistentStoreAndWait];
        [[OWAccountAPIClient sharedClient] updateUserTwitterAccount];
        
        [linkTwitterButton setTitle:CONNECT_STRING forState:UIControlStateNormal];
        [linkTwitterButton addAwesomeIcon:FAIconTwitter beforeTitle:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.updatedProfilePhoto = image;
    self.userView.image = image;
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FBLoginView delegate

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)fbUser {
    NSLog(@"[Facebook]: Logged in user %@", fbUser.description);
    
    if (self.firstNameField.text.length == 0) {
        self.firstNameField.text = [fbUser objectForKey:@"first_name"];
    }
    if (self.lastNameField.text.length == 0) {
        self.lastNameField.text = [fbUser objectForKey:@"last_name"];
    }
    self.facebookID = [fbUser objectForKey:@"id"];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSLog(@"[Facebook]: Logged out");
    user.facebook = facebookID;
    [context MR_saveToPersistentStoreAndWait];
    [[OWAccountAPIClient sharedClient] updateUserFacebookAccount];
    
    if (!self.userView.image) {
        [self importUserAvatarFromFacebook];
    }
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // Upon login, transition to the main UI by pushing it onto the navigation stack.
    NSLog(@"[Facebook]: Logged in");
}

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error{
    NSString *alertMessage, *alertTitle;
    
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // Since this sample uses the FBLoginView, this delegate will respond to
    // login failures, or other failures that have closed the session (such
    // as a token becoming invalid). Please see the [- postOpenGraphAction:]
    // and [- requestPermissionAndPost] on `SCViewController` for further
    // error handling on other operations.
    
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = FACEBOOK_ERROR_STRING;
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures as mentioned. You can inspect
        // the error for more context but this sample generically notifies the user.
        alertTitle = FACEBOOK_ERROR_STRING;
        alertMessage = SESSION_EXPIRED_STRING;
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly, but you should
        // refer to https://developers.facebook.com/docs/technical-guides/iossdk/errors/ for more information.
        alertTitle  = FACEBOOK_ERROR_STRING;
        alertMessage = GENERIC_FACEBOOK_ERROR_STRING;
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:OK_STRING
                          otherButtonTitles:nil] show];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // Facebook SDK * login flow *
    // It is important to always handle session closure because it can happen
    // externally; for example, if the current session's access token becomes
    // invalid. For this sample, we simply pop back to the landing page.
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSLog(@"[Facebook]: Logged out");
    user.facebook = nil;
    [context MR_saveToPersistentStoreAndWait];
    [[OWAccountAPIClient sharedClient] updateUserFacebookAccount];
}

- (void) importUserAvatarFromFacebook {
    NSString *avatarURLString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=false&type=large&return_ssl_resources=1", facebookID];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:avatarURLString]];
    
    AFJSONRequestOperation *jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary *data = [JSON objectForKey:@"data"];
        BOOL isSilhouette = [[data objectForKey:@"is_silhouette"] boolValue];
        if (!isSilhouette) {
            NSString *urlString = [data objectForKey:@"url"];
            NSURL *url = [NSURL URLWithString:urlString];
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url];
            
            AFImageRequestOperation *imageRequestOperation = [AFImageRequestOperation imageRequestOperationWithRequest:imageRequest imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                self.userView.image = image;
                [[OWAccountAPIClient sharedClient] updateUserPhoto:image];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [self showFacebookPhotoImportError];
                NSLog(@"Error getting Facebook profile image: %@", error.userInfo);
            }];
            [imageRequestOperation start];
        } else {
            [self showFacebookPhotoImportError];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self showFacebookPhotoImportError];
        NSLog(@"Error Facebook info for profile image: %@", error.userInfo);
    }];
    [jsonOperation start];
}

- (void) showFacebookPhotoImportError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:FACEBOOK_ERROR_STRING message:IMPORT_FACEBOOK_PHOTO_ERROR_STRING delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles: nil];
    [alert show];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.scrollView setContentOffset:CGPointMake(0, aboutMeLabel.frame.origin.y - 10) animated:YES];
    self.keyboardControls.activeField = textView;
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

@end
