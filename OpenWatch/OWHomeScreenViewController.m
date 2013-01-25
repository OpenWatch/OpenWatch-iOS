//
//  OWHomeScreenViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/29/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWHomeScreenViewController.h"
#import "OWStrings.h"
#import "OWUtilities.h"
#import "OWLoginViewController.h"
#import "OWSettingsController.h"
#import "OWCaptureViewController.h"
#import "OWSettingsViewController.h"
#import "OWWatchViewController.h"
#import "OWAccountAPIClient.h"
#import "OWShareController.h"

#define RECORD_BUTTON_HEIGHT 120.0f
#define RECORD_BUTTON_WIDTH 120.0f
#define BUTTON_HEIGHT 80.0f
#define BUTTON_WIDTH 80.0f

@interface OWHomeScreenViewController ()
@end

@implementation OWHomeScreenViewController
@synthesize recordButtonView, watchButtonView, localButtonView, savedButtonView, settingsButtonView, gridView;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = OPENWATCH_STRING;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [OWUtilities fabricBackgroundPattern];

    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openwatch.png"]];
    imageView.frame = CGRectMake(0, 0, 200, 25);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
    
    CGFloat buttonHeight = BUTTON_HEIGHT;
    CGFloat buttonWidth = BUTTON_WIDTH;
    CGFloat recordButtonHeight = RECORD_BUTTON_HEIGHT;
    CGFloat recordButtonWidth = RECORD_BUTTON_WIDTH;
    self.recordButtonView = [[OWLabeledButtonView alloc] initWithFrame:CGRectMake(0, 0, recordButtonWidth, recordButtonHeight) defaultImageName:@"record-big.png" highlightedImageName:nil labelName:RECORD_STRING];
    self.recordButtonView.textLabel.font = [UIFont boldSystemFontOfSize:25.0f];
    self.watchButtonView = [[OWLabeledButtonView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight) defaultImageName:@"eye-big.png" highlightedImageName:nil labelName:WATCH_STRING];
    self.localButtonView = [[OWLabeledButtonView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight) defaultImageName:@"local-big.png" highlightedImageName:nil labelName:LOCAL_STRING];
    self.savedButtonView = [[OWLabeledButtonView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight) defaultImageName:@"saved-big.png" highlightedImageName:nil labelName:SAVED_STRING];
    self.settingsButtonView = [[OWLabeledButtonView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight) defaultImageName:@"settings-big.png" highlightedImageName:nil labelName:SETTINGS_STRING];
    
    [watchButtonView.button addTarget:self action:@selector(watchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [recordButtonView.button addTarget:self action:@selector(recordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [settingsButtonView.button addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [savedButtonView.button addTarget:self action:@selector(savedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [localButtonView.button addTarget:self action:@selector(localButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.gridView = [[UIView alloc] init];
    
    [gridView addSubview:watchButtonView];
    [gridView addSubview:localButtonView];
    [gridView addSubview:savedButtonView];
    [gridView addSubview:settingsButtonView];
    [self.view addSubview:gridView];
    [self.view addSubview:recordButtonView];

    
    [[OWAccountAPIClient sharedClient] getSubscribedTags];
}



- (void) checkAccount {
    OWSettingsController *settingsController = [OWSettingsController sharedInstance];
    if (![settingsController.account isLoggedIn]) {
        OWLoginViewController *loginViewController = [[OWLoginViewController alloc] init];
        UINavigationController *loginNavController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [OWUtilities styleNavigationController:loginNavController];
        [self presentViewController:loginNavController animated:YES completion:^{
            
        }];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TestFlight passCheckpoint:HOME_CHECKPOINT];
    CGFloat buttonHeight = BUTTON_HEIGHT;
    CGFloat buttonWidth = BUTTON_WIDTH;
    CGFloat recordButtonHeight = RECORD_BUTTON_HEIGHT;
    CGFloat recordButtonWidth = RECORD_BUTTON_WIDTH;
    
    CGFloat xPadding = 50.0f;
    CGFloat yPadding = 10.0f;
    
    CGFloat recordButtonYOrigin = 0.0f;
    
    self.recordButtonView.frame = CGRectMake(self.view.frame.size.width/2 - recordButtonWidth/2, recordButtonYOrigin, recordButtonWidth, recordButtonHeight);
    
    CGFloat firstButtonRowYOrigin = recordButtonYOrigin+recordButtonHeight + yPadding*5;
    gridView.frame = CGRectMake(xPadding, firstButtonRowYOrigin, self.view.frame.size.width-xPadding*2, self.view.frame.size.height - firstButtonRowYOrigin - yPadding*5);
    
    self.watchButtonView.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
    CGFloat secondButtonColumnXOrigin = gridView.frame.size.width - buttonWidth;
    self.localButtonView.frame = CGRectMake(secondButtonColumnXOrigin, 0, buttonWidth, buttonHeight);
    CGFloat secondButtonRowYOrigin = gridView.frame.size.height - buttonHeight;
    self.savedButtonView.frame = CGRectMake(0, secondButtonRowYOrigin, buttonWidth, buttonHeight);
    self.settingsButtonView.frame = CGRectMake(secondButtonColumnXOrigin, secondButtonRowYOrigin, buttonWidth, buttonHeight);
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkAccount];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) settingsButtonPressed:(id)sender {
    OWSettingsViewController *settingsView = [[OWSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsView animated:YES];
}

- (void) recordButtonPressed:(id)sender {
    OWCaptureViewController *captureView = [[OWCaptureViewController alloc] init];
    UINavigationController *captureNav = [[UINavigationController alloc] initWithRootViewController:captureView];
    //[OWUtilities styleNavigationController:captureNav];
    captureNav.navigationBar.tintColor = [OWUtilities navigationBarColor];
    [self presentViewController:captureNav animated:YES completion:^{
    }];
}

- (void) savedButtonPressed:(id)sender {
    OWRecordingListViewController *recordingListView = [[OWRecordingListViewController alloc] init];
    [self.navigationController pushViewController:recordingListView animated:YES];
}

- (void) watchButtonPressed:(id)sender {
    OWFeedType type = kOWFeedTypeFeed;
    NSString *feedString = FEATURED_STRING;
    [self pushWatchVCForFeedName:feedString type:type];
}

- (void) pushWatchVCForFeedName:(NSString*)feedName type:(OWFeedType)type {
    OWWatchViewController *watchVC = [[OWWatchViewController alloc] init];
    [watchVC didSelectFeedWithName:feedName type:type];
    [self.navigationController pushViewController:watchVC animated:YES];
}

- (void) localButtonPressed:(id)sender {
    OWFeedType type = kOWFeedTypeFeed;
    NSString *feedString = LOCAL_STRING;
    [self pushWatchVCForFeedName:feedString type:type];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[OWShareController sharedInstance] shareFromViewController:self];
    }
}

@end
