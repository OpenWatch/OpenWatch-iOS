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

@interface OWProfileViewController : UIViewController <UITextFieldDelegate, BSKeyboardControlsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, FBLoginViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) OWUser *user;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) OWUserProfileView *userView;
@property (nonatomic, strong) UITextField *firstNameField;
@property (nonatomic, strong) UITextField *lastNameField;
@property (nonatomic, strong) UITextField *bioField;
@property (nonatomic, strong) UIButton *choosePhotoButton;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) UIImage *updatedProfilePhoto;

@property (nonatomic, strong) FBLoginView *facebookLoginView;
@property (nonatomic, strong) BButton *linkTwitterButton;

@property (nonatomic, strong) NSString *facebookID;

@end
