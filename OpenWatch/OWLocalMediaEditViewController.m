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
#import "OWShareViewController.h"

#define TAGS_ROW 0
#define PADDING 10.0f

@interface OWLocalMediaEditViewController ()

@end

@implementation OWLocalMediaEditViewController
@synthesize titleTextField, whatHappenedLabel, saveButton, uploadProgressView, objectID, scrollView, showingAfterCapture, previewView, characterCountdown, uploadStatusLabel;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id) init {
    if (self = [super init]) {
        self.title = EDIT_STRING;
        [self setupScrollView];
        [self setupFields];
        [self setupWhatHappenedLabel];
        [self setupProgressView];
        [self setupPreviewView];
        
        self.uploadStatusLabel = [[UILabel alloc] init];
        self.uploadStatusLabel.text = @"It's online!";
        [OWUtilities styleLabel:uploadStatusLabel];
        [self.scrollView addSubview:uploadStatusLabel];
        
        self.characterCountdown = [[OWCharacterCountdownView alloc] initWithFrame:CGRectZero];
        self.showingAfterCapture = NO;
        [self registerForUploadProgressNotifications];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SAVE_STRING style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
        self.navigationItem.rightBarButtonItem.tintColor = [OWUtilities doneButtonColor];
        
        // Listen for keyboard appearances and disappearances
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:self.view.window];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:self.view.window];
    }
    return self;
}

- (void) setupPreviewView {
    self.previewView = [[OWPreviewView alloc] init];
}

- (void) setupScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delaysContentTouches = NO;
}

- (void) setupWhatHappenedLabel {
    self.whatHappenedLabel = [[UILabel alloc] init];
    self.whatHappenedLabel.text = @"Caption";
    self.whatHappenedLabel.backgroundColor = [UIColor clearColor];
    self.whatHappenedLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    self.whatHappenedLabel.textColor = [OWUtilities greyTextColor];
    self.whatHappenedLabel.shadowColor = [UIColor lightGrayColor];
    self.whatHappenedLabel.shadowOffset = CGSizeMake(0, 1);
    [self.scrollView addSubview:whatHappenedLabel];
}

- (void) setupProgressView {
    if (uploadProgressView) {
        [uploadProgressView removeFromSuperview];
    }
    self.uploadProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.scrollView addSubview:uploadProgressView];
}


- (void) refreshProgressView {
    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:self.objectID];
    if ([mediaObject isKindOfClass:[OWLocalRecording class]]) {
        OWLocalRecording *localRecording = (OWLocalRecording*)mediaObject;
        float progress = ((float)[localRecording completedFileCount]) / [localRecording totalFileCount];
        [self.uploadProgressView setProgress:progress animated:YES];
    } else if ([mediaObject isKindOfClass:[OWPhoto class]]){
        OWPhoto *photo = (OWPhoto*)mediaObject;
        if (photo.uploadedValue) {
            [self.uploadProgressView setProgress:1.0f animated:YES];
        } else {
            [self.uploadProgressView setProgress:0.0f animated:YES];
        }
    }
}

- (void) refreshFrames {
    CGFloat padding = PADDING;
    CGFloat contentHeight = 0.0f;
    
    CGFloat titleYOrigin;
    CGFloat itemHeight = 30.0f;
    CGFloat itemWidth = self.view.frame.size.width - padding*2;
    
    CGFloat previewHeight = [OWPreviewView heightForWidth:itemWidth];
    
    self.uploadStatusLabel.frame = CGRectMake(padding, padding, itemWidth, 20.0f);
    
    self.previewView.frame = CGRectMake(padding, [OWUtilities bottomOfView:uploadStatusLabel] + padding, itemWidth, previewHeight);
    
    self.uploadProgressView.frame = CGRectMake(padding, [OWUtilities bottomOfView:previewView] + 5, itemWidth, itemHeight);
    
    CGFloat whatHappenedYOrigin = [OWUtilities bottomOfView:uploadProgressView] + padding;
    self.whatHappenedLabel.frame = CGRectMake(padding,whatHappenedYOrigin, itemWidth, itemHeight);
    titleYOrigin = [OWUtilities bottomOfView:whatHappenedLabel] + padding;
    self.titleTextField.frame = CGRectMake(padding, titleYOrigin, itemWidth, itemHeight);
    self.characterCountdown.frame = CGRectMake(padding, [OWUtilities bottomOfView:titleTextField] + 10, itemWidth, 35);
    contentHeight = [OWUtilities bottomOfView:self.titleTextField] + padding*3;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentHeight);
    self.scrollView.frame = self.view.bounds;
}

- (void) setObjectID:(NSManagedObjectID *)newObjectID {
    objectID = newObjectID;
    
    self.previewView.objectID = objectID;
    
    [self refreshFields];
    [self refreshFrames];
    [self refreshProgressView];
    [self registerForUploadProgressNotifications];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshFrames];
    [self registerForUploadProgressNotifications];
    [TestFlight passCheckpoint:EDIT_METADATA_CHECKPOINT];
    [self checkRecording];
    if (showingAfterCapture) {
        [self.navigationItem setHidesBackButton:YES];
    }
}


- (void) registerForUploadProgressNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOWCaptureAPIClientBandwidthNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUploadProgressNotification:) name:kOWCaptureAPIClientBandwidthNotification object:nil];
}

- (void) refreshFields {
    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:objectID];
    NSString *title = mediaObject.title;
    if (title) {
        self.titleTextField.text = title;
    } else {
        self.titleTextField.text = @"";
    }
    [self.characterCountdown updateText:titleTextField.text];
}

- (UITextField*)textFieldWithDefaults {
    UITextField *textField = [[UITextField alloc] init];
    textField.delegate = self;
    textField.autocorrectionType = UITextAutocorrectionTypeDefault;
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textColor = [OWUtilities textFieldTextColor];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    return textField;
}

-(void)setupFields {
    if (titleTextField) {
        [titleTextField removeFromSuperview];
    }
    self.titleTextField = [self textFieldWithDefaults];
    self.titleTextField.placeholder = @"What happened? #tags #okay";
    
    [self.scrollView addSubview:titleTextField];
}


- (void) receivedUploadProgressNotification:(NSNotification*)notification {
    [self refreshProgressView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view addSubview:scrollView];
    [self.scrollView addSubview:previewView];
    [self.scrollView addSubview:characterCountdown];
}

- (BOOL) checkFields {
    if (self.titleTextField.text.length > 2) {
        return YES;
    }
    return NO;
}

- (void) saveButtonPressed:(id)sender {
    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:self.objectID];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    mediaObject.title = self.titleTextField.text;
    [context MR_saveToPersistentStoreAndWait];    
    
    [[OWAccountAPIClient sharedClient] postObjectWithUUID:mediaObject.uuid objectClass:[mediaObject class] success:nil failure:nil];
    
    [self.view endEditing:YES];
    
    if (showingAfterCapture) {
        OWShareViewController *shareView = [[OWShareViewController alloc] init];
        shareView.mediaObject = mediaObject;
        [self.navigationController pushViewController:shareView animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [self.scrollView setContentOffset:CGPointMake(0, titleTextField.frame.origin.y - PADDING) animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [NSString stringWithFormat:@"%@%@", textField.text, string];
    BOOL shouldChangeCharacters = [self.characterCountdown updateText:newText];
    if (!shouldChangeCharacters && string.length == 0) {
        return YES;
    }
    return shouldChangeCharacters;
}


- (void)keyboardWillShow: (NSNotification *) notif{}

- (void)keyboardWillHide: (NSNotification *) notif {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
