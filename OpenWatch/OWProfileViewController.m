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

@interface OWProfileViewController ()

@end

@implementation OWProfileViewController
@synthesize userView, firstNameField, lastNameField, bioField, user, choosePhotoButton, scrollView, keyboardControls, imagePicker;
@synthesize updatedProfilePhoto;

- (id)init
{
    self = [super init];
    if (self) {
        self.scrollView = [[UIScrollView alloc] init];
        [self.view addSubview:scrollView];
        
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
        [choosePhotoButton addAwesomeIcon:FAIconCamera beforeTitle:YES];

        [self.choosePhotoButton addTarget:self action:@selector(choosePhotoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
        doneButton.tintColor = [OWUtilities doneButtonColor];
        self.navigationItem.rightBarButtonItem = doneButton;
        
        [self.scrollView addSubview:userView];
        [self.scrollView addSubview:firstNameField];
        [self.scrollView addSubview:lastNameField];
        [self.scrollView addSubview:bioField];
        [self.scrollView addSubview:choosePhotoButton];
    }
    return self;
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
    self.user.bio = self.bioField.text;
    
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
    
    CGFloat userViewHeight = 100.0f;
    self.userView.frame = CGRectMake(padding, padding, paddedWidth, userViewHeight);
    self.choosePhotoButton.frame = CGRectMake(padding, [OWUtilities bottomOfView:userView] + padding, paddedWidth, 40);
    CGFloat fieldHeight = 30.0f;
    CGFloat fieldXOrigin = padding;
    self.firstNameField.frame = CGRectMake(fieldXOrigin, [OWUtilities bottomOfView:choosePhotoButton] + padding, paddedWidth, fieldHeight);
    self.lastNameField.frame = CGRectMake(fieldXOrigin, [OWUtilities bottomOfView:firstNameField] + padding, paddedWidth, fieldHeight);
    self.bioField.frame = CGRectMake(fieldXOrigin, [OWUtilities bottomOfView:lastNameField] + padding, paddedWidth, fieldHeight);
    self.scrollView.contentSize = CGSizeMake(paddedWidth, [OWUtilities bottomOfView:bioField]);
}

- (void) setUser:(OWUser *)newUser {
    user = newUser;
    self.title = user.username;
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
    [self.scrollView setContentOffset:CGPointMake(0, firstNameField.frame.origin.y - 10) animated:YES];
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
    [actionSheet showInView:self.view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
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
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.updatedProfilePhoto = image;
    self.userView.profileImageView.image = image;
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}


@end
