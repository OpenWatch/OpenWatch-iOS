//
//  OWProfileViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/30/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWUser.h"
#import "BButton.h"
#import "OWUserProfileView.h"
#import "BSKeyboardControls.h"
#import "FacebookSDK.h"
#import "SLGlowingTextField.h"
#import "SSTextView.h"

@interface OWProfileViewController : UIViewController <UITextFieldDelegate, BSKeyboardControlsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, FBLoginViewDelegate, UIAlertViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) OWUser *user;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) OWUserProfileView *userView;
@property (nonatomic, strong) SLGlowingTextField *firstNameField;
@property (nonatomic, strong) SLGlowingTextField *lastNameField;
@property (nonatomic, strong) SSTextView *aboutMeTextView;
@property (nonatomic, strong) UIButton *choosePhotoButton;

@property (nonatomic, strong) UILabel *firstNameLabel;
@property (nonatomic, strong) UILabel *lastNameLabel;
@property (nonatomic, strong) UILabel *aboutMeLabel;
@property (nonatomic, strong) UILabel *connectAccountsLabel;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) UIImage *updatedProfilePhoto;

@property (nonatomic, strong) FBLoginView *facebookLoginView;
@property (nonatomic, strong) BButton *linkTwitterButton;

@property (nonatomic, strong) NSString *facebookID;

@end
