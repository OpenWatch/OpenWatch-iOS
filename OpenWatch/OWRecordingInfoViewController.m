//
//  OWRecordingInfoViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/26/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWRecordingInfoViewController.h"
#import "OWStrings.h"

@interface OWRecordingInfoViewController ()

@end

@implementation OWRecordingInfoViewController
@synthesize recording, titleTextField, descriptionTextField;

- (id) initWithRecording:(OWRecording *)newRecording {
    if (self = [super init]) {
        self.recording = newRecording;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

-(void)setupFields {
    self.titleTextField = [self textFieldWithDefaults];
    self.titleTextField.placeholder = REQUIRED_STRING;
    NSString *title = recording.title;
    if (title) {
        self.titleTextField.text = title;
    }
    [self addCellInfoWithSection:0 row:0 labelText:TITLE_STRING cellType:kCellTypeTextField userInputView:self.titleTextField];
    
    self.descriptionTextField = [self textFieldWithDefaults];
    NSString *description = recording.recordingDescription;
    if (description) {
        self.descriptionTextField.text = description;
    }
    [self addCellInfoWithSection:0 row:1 labelText:DESCRIPTION_STRING cellType:kCellTypeTextField userInputView:self.descriptionTextField];
}

- (UITextField*)textFieldWithDefaults {
    UITextField *textField = [[UITextField alloc] init];
    textField.delegate = self;
    textField.autocorrectionType = UITextAutocorrectionTypeDefault;
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textColor = self.textFieldTextColor;
    return textField;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupFields];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
