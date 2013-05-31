//
//  OWProfileView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/30/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWProfileView.h"
#import "OWUtilities.h"
#import "OWSettingsController.h"
#import <QuartzCore/QuartzCore.h>

@implementation OWProfileView
@synthesize userView, firstNameField, lastNameField, bioField, user, choosePhotoButton, scrollView, keyboardControls;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] init];
        [self addSubview:scrollView];

        self.userView = [[OWUserView alloc] initWithFrame:CGRectZero];
        self.firstNameField = [[UITextField alloc] init];
        self.firstNameField.delegate = self;
        self.firstNameField.placeholder = @"First Name";
        self.lastNameField = [[UITextField alloc] init];
        self.lastNameField.placeholder = @"Last Name";
        self.lastNameField.delegate = self;
        self.bioField = [[UITextField alloc] init];
        self.bioField.placeholder = @"About Yourself";
        self.bioField.delegate = self;
        
        NSArray *fields = @[firstNameField, lastNameField, bioField];
        
        self.keyboardControls = [[BSKeyboardControls alloc] initWithFields:fields];
        self.keyboardControls.delegate = self;
        
        self.choosePhotoButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeDefault];
        [self.choosePhotoButton setTitle:@"Choose Photo" forState:UIControlStateNormal];
        [self.choosePhotoButton addTarget:self action:@selector(choosePhotoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *doneButton = [UIBarButtonItem
        
        [self.scrollView addSubview:userView];
        [self.scrollView addSubview:firstNameField];
        [self.scrollView addSubview:lastNameField];
        [self.scrollView addSubview:bioField];
        [self.scrollView addSubview:choosePhotoButton];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    
    CGFloat padding = 10.0f;
    CGFloat frameWidth = frame.size.width;
    CGFloat userViewHeight = 100.0f;
    self.userView.frame = CGRectMake(0, 0, frameWidth, userViewHeight);
    self.choosePhotoButton.frame = CGRectMake(0, [OWUtilities bottomOfView:userView] + padding, frameWidth, 30);
    CGFloat fieldHeight = 30.0f;
    CGFloat fieldXOrigin = 0;
    self.firstNameField.frame = CGRectMake(fieldXOrigin, [OWUtilities bottomOfView:choosePhotoButton] + padding, frameWidth, fieldHeight);
    self.lastNameField.frame = CGRectMake(fieldXOrigin, [OWUtilities bottomOfView:firstNameField] + padding, frameWidth, fieldHeight);
    self.bioField.frame = CGRectMake(fieldXOrigin, [OWUtilities bottomOfView:lastNameField] + padding, frameWidth, fieldHeight);
    self.scrollView.contentSize = CGSizeMake(frameWidth, [OWUtilities bottomOfView:bioField]);
}

- (void) setUser:(OWUser *)newUser {
    user = newUser;
    OWUser *globalUser = [OWSettingsController sharedInstance].account.user;
    BOOL showField = YES;
    CGFloat opacity = 1.0f;
    UITextBorderStyle borderStyle = UITextBorderStyleRoundedRect;
    if (![globalUser.objectID isEqual:newUser.objectID]) {
        showField = NO;
        opacity = 0.0f;
        borderStyle = UITextBorderStyleNone;
        [choosePhotoButton removeFromSuperview];
    }
    self.firstNameField.enabled = showField;
    self.firstNameField.borderStyle = borderStyle;
    self.lastNameField.enabled = showField;
    self.lastNameField.borderStyle = borderStyle;
    self.bioField.enabled = showField;
    self.bioField.borderStyle = borderStyle;

    self.firstNameField.text = user.firstName;
    self.lastNameField.text = user.lastName;
    self.bioField.text = user.bio;
    
    self.userView.user = user;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyControls
{
    [keyControls.activeField resignFirstResponder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [self.scrollView setContentOffset:CGPointMake(0, firstNameField.frame.origin.y) animated:YES];
    [self.keyboardControls setActiveField:textField];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (void) choosePhotoButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Picture", @"Choose from Camera Roll", nil];
    [actionSheet showInView:self];
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    NSLog(@"%d", buttonIndex);
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
    }
    if (buttonIndex == 1) {
        sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        self.imagePicker.sourceType = sourceType;
    }

}

@end
