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
#import "OWShareController.h"
#import "OWTag.h"
#import "MBProgressHUD.h"
#import "OWSettingsController.h"
#import "OWLocalMediaController.h"
#import "OWPhoto.h"

#define TAGS_ROW 0
#define PADDING 10.0f

@interface OWLocalMediaEditViewController ()

@end

@implementation OWLocalMediaEditViewController
@synthesize titleTextField, whatHappenedLabel, saveButton, uploadProgressView, objectID, scrollView, showingAfterCapture, previewView;

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
    self.whatHappenedLabel.text = WHAT_HAPPENED_STRING;
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
        if (photo.uploaded) {
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
    
    self.previewView.frame = CGRectMake(padding, padding, itemWidth, 200);
    
    self.uploadProgressView.frame = CGRectMake(padding, [OWUtilities bottomOfView:previewView], itemWidth, itemHeight);
    
    CGFloat whatHappenedYOrigin = [OWUtilities bottomOfView:uploadProgressView] + padding;
    self.whatHappenedLabel.frame = CGRectMake(padding,whatHappenedYOrigin, itemWidth, itemHeight);
    titleYOrigin = [OWUtilities bottomOfView:whatHappenedLabel] + padding;
    self.titleTextField.frame = CGRectMake(padding, titleYOrigin, itemWidth, itemHeight);
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
    self.titleTextField.placeholder = TITLE_STRING;
    
    [self.scrollView addSubview:titleTextField];
}


- (void) receivedUploadProgressNotification:(NSNotification*)notification {
    [self refreshProgressView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view addSubview:scrollView];
}

- (BOOL) checkFields {
    if (self.titleTextField.text.length > 2) {
        return YES;
    }
    return NO;
}

- (void) saveButtonPressed:(id)sender {
    if (![self checkFields]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NEEDS_TITLE_STRING message:NEEDS_TITLE_MESSAGE_STRING delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles: nil];
        [alert show];
        return;
    }
    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:self.objectID];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    mediaObject.title = self.titleTextField.text;
    [context MR_saveToPersistentStoreAndWait];
    
    [[OWAccountAPIClient sharedClient] postObjectWithUUID:mediaObject.uuid objectClass:[mediaObject class] success:nil failure:nil];
    
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SHARE_STRING message:SHARE_MESSAGE_STRING delegate:OW_APP_DELEGATE.dashboardViewController cancelButtonTitle:NO_STRING otherButtonTitles:YES_STRING, nil];
        [OWShareController sharedInstance].mediaObjectID = self.objectID;
        [alert show];
    }];
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
