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

#define TAGS_ROW 0


@interface OWRecordingEditViewController ()

@end

@implementation OWRecordingEditViewController
@synthesize titleTextField, descriptionTextField, whatHappenedLabel, saveButton, uploadProgressView, recordingID, scrollView;

- (id) init {
    if (self = [super init]) {
        [self setupScrollView];
        [self setupFields];
        [self setupWhatHappenedLabel];
        [self setupProgressView];
    }
    return self;
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
    CGFloat padding = 10.0f;
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
    CGFloat tableViewYOrigin = [OWUtilities bottomOfView:descriptionTextField] + padding;
    self.groupedTableView.frame = CGRectMake(0, tableViewYOrigin, self.view.frame.size.width, 70.0f);
    contentHeight = [OWUtilities bottomOfView:self.groupedTableView] + padding*3;
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentHeight);
    self.scrollView.frame = self.view.bounds;
}

- (void) setRecordingID:(NSManagedObjectID *)newRecordingID {
    recordingID = newRecordingID;
    
    [self refreshFields];
    [self refreshFrames];
    [self refreshProgressView];
    [self registerForUploadProgressNotifications];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SAVE_STRING style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
    self.navigationItem.rightBarButtonItem.tintColor = [OWUtilities doneButtonColor];
    [self.groupedTableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshFrames];
    [self registerForUploadProgressNotifications];
}


- (void) registerForUploadProgressNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    OWLocalRecording *recording = [OWRecordingController recordingForObjectID:self.recordingID];
    if (recording) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUploadProgressNotification:) name:kOWCaptureAPIClientBandwidthNotification object:nil];
    }
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
}


- (UITextField*)textFieldWithDefaults {
    UITextField *textField = [[UITextField alloc] init];
    textField.delegate = self;
    textField.autocorrectionType = UITextAutocorrectionTypeDefault;
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textColor = self.textFieldTextColor;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    return textField;
}

-(void)setupFields {
    self.tableViewArray = [[NSMutableArray alloc] init];
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
    
    [self addCellInfoWithSection:0 row:TAGS_ROW labelText:TAGS_STRING cellType:kCellTypeNone userInputView:nil];
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
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
