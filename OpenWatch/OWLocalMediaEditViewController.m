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
#import "OWSocialController.h"
#import "OWSocialTableItem.h"

#define TAGS_ROW 0
#define PADDING 10.0f

static NSString *cellIdentifier = @"CellIdentifier";

@interface OWLocalMediaEditViewController ()

@end

@implementation OWLocalMediaEditViewController
@synthesize titleTextField, whatHappenedLabel, saveButton, objectID, scrollView, showingAfterCapture, previewView, characterCountdown, previewGestureRecognizer, primaryTag, keyboardControls, socialTableView, facebookSwitch, twitterSwitch, openwatchSwitch;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setupSocialSwitches {
    self.facebookSwitch = [[UISwitch alloc] init];
    [self.facebookSwitch addTarget:self action:@selector(toggleFacebookSwitch:) forControlEvents:UIControlEventValueChanged];
    OWSocialTableItem *facebookItem = [[OWSocialTableItem alloc] initWithSwitch:facebookSwitch image:[UIImage imageNamed:@"208-facebook.png"] text:POST_TO_FACEBOOK_STRING];
    
    self.twitterSwitch = [[UISwitch alloc] init];
    [self.twitterSwitch addTarget:self action:@selector(toggleTwitterSwitch:) forControlEvents:UIControlEventValueChanged];
    OWSocialTableItem *twitterItem = [[OWSocialTableItem alloc] initWithSwitch:twitterSwitch image:[UIImage imageNamed:@"210-twitterbird.png"] text:POST_TO_TWITTER_STRING];

    self.openwatchSwitch = [[UISwitch alloc] init];
    OWSocialTableItem *openWatchItem = [[OWSocialTableItem alloc] initWithSwitch:openwatchSwitch image:nil text:POST_TO_OPENWATCH_STRING];
    
    self.socialItems = @[openWatchItem, facebookItem, twitterItem];
}

- (void) toggleFacebookSwitch:(id)sender {
    
}

- (void) toggleTwitterSwitch:(id)sender {
    if (self.twitterSwitch.on) {
        [[OWSocialController sharedInstance] fetchTwitterAccountForViewController:self callbackBlock:^(ACAccount *selectedAccount, NSError *error) {
            if (error) {
                [self.twitterSwitch setOn:NO animated:YES];
            } else {
                NSLog(@"Twitter account selected: %@", selectedAccount);
            }
        }];
    }
}

- (void) setupSocialTable {
    self.socialTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.socialTableView.dataSource = self;
    self.socialTableView.scrollEnabled = NO;
    self.socialTableView.backgroundColor = [UIColor clearColor];
    self.socialTableView.backgroundView = nil;
    [self.socialTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.scrollView addSubview:socialTableView];
}

- (id) init {
    if (self = [super init]) {
        self.title = EDIT_STRING;
        [self setupScrollView];
        [self setupFields];
        [self setupWhatHappenedLabel];
        [self setupPreviewView];
        [self setupSocialSwitches];
        [self setupSocialTable];
        
        self.keyboardControls = [[BSKeyboardControls alloc] initWithFields:@[titleTextField]];
        self.keyboardControls.delegate = self;
        
        self.characterCountdown = [[OWCharacterCountdownView alloc] initWithFrame:CGRectZero];
        [self.scrollView addSubview:characterCountdown];
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
    self.previewView.moviePlayer.shouldAutoplay = YES;
    [self.scrollView addSubview:previewView];
}

- (void) setupScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delaysContentTouches = NO;
    self.scrollView.backgroundColor = [OWUtilities stoneBackgroundPattern];
    [self.view addSubview:scrollView];
}

- (void) setupWhatHappenedLabel {
    self.whatHappenedLabel = [[UILabel alloc] init];
    self.whatHappenedLabel.text = CAPTION_STRING;
    self.whatHappenedLabel.backgroundColor = [UIColor clearColor];
    self.whatHappenedLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    self.whatHappenedLabel.textColor = [OWUtilities greyTextColor];
    self.whatHappenedLabel.shadowColor = [UIColor lightGrayColor];
    self.whatHappenedLabel.shadowOffset = CGSizeMake(0, 1);
    [self.scrollView addSubview:whatHappenedLabel];
}

- (void) refreshFrames {
    CGFloat padding = PADDING;
    CGFloat contentHeight = 0.0f;
    
    CGFloat titleYOrigin;
    CGFloat itemHeight = 30.0f;
    CGFloat frameWidth = self.view.frame.size.width;
    CGFloat itemWidth = frameWidth - padding*2;
    
    CGFloat previewHeight = [OWPreviewView heightForWidth:itemWidth];
        
    self.previewView.frame = CGRectMake(padding, padding, itemWidth, previewHeight);
        
    CGFloat whatHappenedYOrigin = [OWUtilities bottomOfView:previewView] + padding;
    self.whatHappenedLabel.frame = CGRectMake(padding,whatHappenedYOrigin, itemWidth, itemHeight);
    titleYOrigin = [OWUtilities bottomOfView:whatHappenedLabel] + padding;
    self.titleTextField.frame = CGRectMake(padding, titleYOrigin, itemWidth, itemHeight);
    self.characterCountdown.frame = CGRectMake(padding, [OWUtilities bottomOfView:titleTextField] + 10, itemWidth, 35);
    
    self.socialTableView.frame = CGRectMake(0, [OWUtilities bottomOfView:self.titleTextField], frameWidth, 155);
    
    contentHeight = [OWUtilities bottomOfView:self.socialTableView] + padding*3;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentHeight);
    self.scrollView.frame = self.view.bounds;
}

- (void) setObjectID:(NSManagedObjectID *)newObjectID {
    objectID = newObjectID;
    
    self.previewView.objectID = objectID;
    
    if (previewView.gestureRecognizer) {
        self.previewGestureRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(togglePreviewFullscreen)];
        previewGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:previewGestureRecognizer];
    }
    
    [self refreshFields];
    [self refreshFrames];
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

- (void) setPrimaryTag:(NSString *)newPrimaryTag {
    primaryTag = newPrimaryTag;
    self.characterCountdown.maxCharacters = 250-primaryTag.length;
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
    self.titleTextField.keyboardType = UIKeyboardTypeTwitter;
    self.titleTextField.placeholder = WHAT_HAPPENED_LABEL_STRING;
    
    [self.scrollView addSubview:titleTextField];
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
    
    NSMutableString *finalTitleString = [[NSMutableString alloc] init];
    NSString *initialTitleString = self.titleTextField.text;
    int tagLength = primaryTag.length;
    
    // define the range you're interested in
    NSRange stringRange = {0, MIN([initialTitleString length], self.characterCountdown.maxCharacters-tagLength)};
    
    // adjust the range to include dependent chars
    stringRange = [initialTitleString rangeOfComposedCharacterSequencesForRange:stringRange];
    
    // Now you can create the short string
    NSString *shortString = [initialTitleString substringWithRange:stringRange];
    [finalTitleString appendString:shortString];
    if (primaryTag) {
        [finalTitleString appendFormat:@" #%@", primaryTag];
    }
    
    NSString *trimmedText = [finalTitleString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    mediaObject.title = trimmedText;
    [context MR_saveToPersistentStoreAndWait];    
    
    [[OWAccountAPIClient sharedClient] postObjectWithUUID:mediaObject.uuid objectClass:[mediaObject class] success:nil failure:nil retryCount:kOWAccountAPIClientDefaultRetryCount];
    
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
    } retryCount:kOWAccountAPIClientDefaultRetryCount];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [self.scrollView setContentOffset:CGPointMake(0, titleTextField.frame.origin.y - PADDING) animated:YES];
    [self.keyboardControls setActiveField:textField];
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

- (void) togglePreviewFullscreen {
    // moved to delegate method because this isn't firing for some reason
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)newGestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{
    BOOL shouldReceiveTouch = YES;
    
    if (newGestureRecognizer == previewGestureRecognizer) {
        shouldReceiveTouch = (touch.view == self.previewView);
    }
    
    if (shouldReceiveTouch) {
        [self.previewView toggleFullscreen];
    }
    
    return shouldReceiveTouch;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyControls
{
    [keyControls.activeField resignFirstResponder];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.socialItems.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OWSocialTableItem *socialItem = [self.socialItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = socialItem.text;
    cell.imageView.image = socialItem.image;
    cell.accessoryView = socialItem.socialSwitch;
    return cell;
}

@end
