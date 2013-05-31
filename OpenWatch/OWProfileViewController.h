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
#import "OWUserView.h"
#import "BSKeyboardControls.h"

@interface OWProfileViewController : UIViewController <UITextFieldDelegate, BSKeyboardControlsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) OWUser *user;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) OWUserView *userView;
@property (nonatomic, strong) UITextField *firstNameField;
@property (nonatomic, strong) UITextField *lastNameField;
@property (nonatomic, strong) UITextField *bioField;
@property (nonatomic, strong) BButton *choosePhotoButton;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@property (nonatomic, strong) UIImagePickerController *imagePicker;


@end
