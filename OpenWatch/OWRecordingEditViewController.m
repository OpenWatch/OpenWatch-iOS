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
#import "OWTagEditViewController.h"
#import "OWUtilities.h"
#import "OWAppDelegate.h"
#import "OWShareController.h"
#import "OWTag.h"

#define TAGS_ROW 0
#define PADDING 10.0f

@interface OWRecordingEditViewController ()

@end

@implementation OWRecordingEditViewController
@synthesize titleTextField, descriptionTextField, whatHappenedLabel, saveButton, uploadProgressView, recordingID, scrollView, tagList, tagCreationView;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id) init {
    if (self = [super init]) {
        [self setupScrollView];
        [self setupFields];
        [self setupWhatHappenedLabel];
        [self setupProgressView];
        [self setupTagView];
        [self setupTagCreationView];
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

- (void) setupTagView {
    self.tagList = [[DWTagList alloc] initWithFrame:CGRectZero];
    self.tagList.delegate = self;
    [self.scrollView addSubview:tagList];
}

- (void) setupTagCreationView {
    self.tagCreationView = [[OWTagCreationView alloc] initWithFrame:CGRectZero];
    self.tagCreationView.delegate = self;
    self.tagCreationView.textField.placeholder = TAGS_STRING;
    [self.scrollView addSubview:tagCreationView];
}

- (void) setupScrollView {
    self.scrollView = [[UIScrollView alloc] init];
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
    OWLocalRecording *recording = [OWRecordingController recordingForObjectID:self.recordingID];
    if (recording) {
        float progress = ((float)[recording completedFileCount]) / [recording totalFileCount];
        [self.uploadProgressView setProgress:progress animated:YES];
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
    self.tagCreationView.frame = CGRectMake(padding, [OWUtilities bottomOfView:descriptionTextField] + padding, itemWidth, itemHeight);
    self.tagList.frame = CGRectMake(padding, [OWUtilities bottomOfView:tagCreationView] + padding, itemWidth, itemHeight);
    [self.tagList display];
    [self refreshTaglistFrame];
    contentHeight = [OWUtilities bottomOfView:self.tagList] + padding*3;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentHeight);
    self.scrollView.frame = self.view.bounds;
}

- (void) refreshTaglistFrame {
    CGRect tagListFrame = self.tagList.frame;
    tagListFrame.size.height = self.tagList.fittedSize.height;
    self.tagList.frame = tagListFrame;
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
    NSSet *tagSet = recording.user.tags;
    NSMutableArray *tagNameArray = [[NSMutableArray alloc] initWithCapacity:tagSet.count];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *tagObjectArray = [tagSet sortedArrayUsingDescriptors:@[sortDescriptor]];
    for (OWTag *tag in tagObjectArray) {
        [tagNameArray addObject:tag.name];
    }
    [tagList setTags:tagNameArray];
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
	[self.view addSubview:scrollView];
}

- (void) saveButtonPressed:(id)sender {
    OWLocalRecording *recording = [OWRecordingController recordingForObjectID:self.recordingID];
    recording.title = self.titleTextField.text;
    recording.recordingDescription = self.descriptionTextField.text;
    
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


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == TAGS_ROW) {
        OWTagEditViewController *tagEditor = [[OWTagEditViewController alloc] init];
        tagEditor.recordingObjectID = self.recordingID;
        tagEditor.isLocalRecording = YES;
        [self.navigationController pushViewController:tagEditor animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) selectedTag:(NSString *)tagName {
    NSLog(@"selected: %@", tagName);
}

- (void) tagCreationView:(OWTagCreationView*)tagCreationView didSelectTags:(NSArray*)tagListArray {
    NSMutableSet *mutableTagNamesSet = [NSMutableSet setWithArray:tagList.textArray];
    for (NSString *tagName in tagListArray) {
        [mutableTagNamesSet addObject:tagName];
        NSLog(@"added tag: %@", tagName);
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    NSArray *sortedArray = [mutableTagNamesSet sortedArrayUsingDescriptors:@[sortDescriptor]];
    [tagList setTags:sortedArray];
    [self refreshTaglistFrame];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [self.scrollView setContentOffset:CGPointMake(0, titleTextField.frame.origin.y - PADDING) animated:YES];
}

- (void) tagCreationViewDidBeginEditing:(OWTagCreationView *)_tagCreationView {
    [self.scrollView setContentOffset:CGPointMake(0, _tagCreationView.frame.origin.y - PADDING) animated:YES];
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
