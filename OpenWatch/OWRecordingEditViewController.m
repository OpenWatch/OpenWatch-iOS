//
//  OWRecordingEditViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/17/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWRecordingEditViewController.h"
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

#define TAGS_ROW 0
#define PADDING 10.0f

@interface OWRecordingEditViewController ()

@end

@implementation OWRecordingEditViewController
@synthesize titleTextField, descriptionTextField, whatHappenedLabel, saveButton, uploadProgressView, recordingID, scrollView, tagEditView, showingAfterCapture;

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

- (void) setupTagEditView {
    CGFloat width = 320.0f; // HACK
    CGFloat height = 300.0f; // HACK FIX THIS
    self.tagEditView = [[OWTagEditView alloc] initWithFrame:CGRectMake(PADDING, 0, width - PADDING*2, height)];
    self.tagEditView.delegate = self;
    //self.tagEditView.autoresizesSubviews =
    self.tagEditView.viewForAutocompletionPopover = self.view;
    [self.scrollView addSubview:tagEditView];
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
    OWManagedRecording *recording = [OWRecordingController recordingForObjectID:self.recordingID];
    if ([recording isKindOfClass:[OWLocalRecording class]]) {
        OWLocalRecording *localRecording = (OWLocalRecording*)recording;
        float progress = ((float)[localRecording completedFileCount]) / [localRecording totalFileCount];
        [self.uploadProgressView setProgress:progress animated:YES];
    } else {
        [self.uploadProgressView setProgress:1.0];
    }
}

- (void) refreshFrames {
    CGFloat padding = PADDING;
    CGFloat contentHeight = 0.0f;
    
    CGFloat titleYOrigin;
    CGFloat itemHeight = 30.0f;
    CGFloat itemWidth = self.view.frame.size.width - padding*2;
    self.uploadProgressView.frame = CGRectMake(padding, padding, itemWidth, itemHeight);
    
    CGFloat whatHappenedYOrigin = [OWUtilities bottomOfView:uploadProgressView] + padding;
    self.whatHappenedLabel.frame = CGRectMake(padding,whatHappenedYOrigin, itemWidth, itemHeight);
    titleYOrigin = [OWUtilities bottomOfView:whatHappenedLabel] + padding;
    self.titleTextField.frame = CGRectMake(padding, titleYOrigin, itemWidth, itemHeight);
    CGFloat descriptionYOrigin = [OWUtilities bottomOfView:titleTextField] + padding;
    self.descriptionTextField.frame = CGRectMake(padding, descriptionYOrigin, itemWidth, 100.0f);
        contentHeight = [OWUtilities bottomOfView:self.tagEditView] + padding*3;
    [self refreshTagEditViewFrame];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentHeight);
    self.scrollView.frame = self.view.bounds;
}

- (void) refreshTagEditViewFrame {
    CGFloat itemWidth = self.view.frame.size.width - PADDING*2;
    CGFloat tagViewHeight = tagEditView.contentSize.height;
    self.tagEditView.frame = CGRectMake(PADDING, [OWUtilities bottomOfView:descriptionTextField] + PADDING, itemWidth, tagViewHeight);
}



- (void) setRecordingID:(NSManagedObjectID *)newRecordingID {
    recordingID = newRecordingID;
    
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
    OWManagedRecording *recording = [OWRecordingController recordingForObjectID:self.recordingID];
    NSString *title = recording.title;
    if (title) {
        self.titleTextField.text = title;
    } else {
        self.titleTextField.text = @"";
    }
    NSString *description = recording.recordingDescription;
    if (description) {
        self.descriptionTextField.text = description;
    } else {
        self.descriptionTextField.text = @"";
    }
    NSSet *tagSet = recording.tags;
    tagEditView.tags = tagSet;
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
    
    if (descriptionTextField) {
        [descriptionTextField removeFromSuperview];
    }
    self.descriptionTextField = [self textFieldWithDefaults];
    self.descriptionTextField.placeholder = DESCRIPTION_STRING;
    
    [self.scrollView addSubview:descriptionTextField];    
}


- (void) receivedUploadProgressNotification:(NSNotification*)notification {
    [self refreshProgressView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTagEditView];
	[self.view addSubview:scrollView];
}

- (void) saveButtonPressed:(id)sender {
    OWManagedRecording *recording = [OWRecordingController recordingForObjectID:self.recordingID];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    recording.title = self.titleTextField.text;
    recording.recordingDescription = self.descriptionTextField.text;
    recording.tags = tagEditView.tags;
    
    OWAccount *account = [[OWSettingsController sharedInstance] account];
    OWUser *user = account.user;
    NSMutableSet *tagSet = user.tagsSet;
    [tagSet addObjectsFromArray:[recording.tags allObjects]];
    user.tags = tagSet;
    [context MR_saveToPersistentStoreAndWait];
    
    [recording saveMetadata];
    [[OWAccountAPIClient sharedClient] postRecordingWithUUID:recording.uuid success:nil failure:nil];
    
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SHARE_STRING message:SHARE_MESSAGE_STRING delegate:OW_APP_DELEGATE.homeScreen cancelButtonTitle:NO_STRING otherButtonTitles:YES_STRING, nil];
        [OWShareController sharedInstance].mediaObjectID = self.recordingID;
        [alert show];
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) checkRecording {
    if (showingAfterCapture) {
        [self refreshFields];
        return;
    }
    OWManagedRecording *recording = [OWRecordingController recordingForObjectID:self.recordingID];
    if (![recording isKindOfClass:[OWLocalRecording class]]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[OWAccountAPIClient sharedClient] getRecordingWithUUID:recording.uuid success:^(NSManagedObjectID *recordingObjectID) {
            [self refreshFields];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(NSString *reason) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [self.scrollView setContentOffset:CGPointMake(0, titleTextField.frame.origin.y - PADDING) animated:YES];
}

- (void) tagEditViewDidBeginEditing:(OWTagEditView *)_tagEditView {
    [self.scrollView setContentOffset:CGPointMake(0, tagEditView.frame.origin.y - PADDING) animated:YES];
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

@end
