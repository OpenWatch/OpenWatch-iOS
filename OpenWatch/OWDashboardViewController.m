//
//  OWDashboardViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWDashboardViewController.h"
#import "OWUtilities.h"
#import "OWShareController.h"
#import "OWCaptureViewController.h"
#import "OWAccountAPIClient.h"
#import "OWSettingsViewController.h"
#import "OWRecordingListViewController.h"
#import "OWStrings.h"
#import "OWFeedViewController.h"


@interface OWDashboardViewController ()

@end

@implementation OWDashboardViewController
@synthesize actionBarView, onboardingImageView;

- (id)init
{
    self = [super init];
    if (self) {
        self.actionBarView = [[OWActionBarView alloc] init];
        self.actionBarView.delegate = self;
        self.onboardingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ow_space1.jpg"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view addSubview:actionBarView];
    [self.view addSubview:onboardingImageView];
    
    self.view.backgroundColor = [OWUtilities stoneBackgroundPattern];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openwatch.png"]];
    imageView.frame = CGRectMake(0, 0, 200, 25);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
    
    
    [[OWAccountAPIClient sharedClient] getSubscribedTags];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.actionBarView.frame = CGRectMake(0, 0, self.view.frame.size.width, 70);
    self.onboardingImageView.frame = CGRectMake(0, [OWUtilities bottomOfView:actionBarView], self.view.frame.size.width, self.onboardingImageView.image.size.height);
}

- (void) actionBarView:(OWActionBarView *)actionBarView didSelectButtonAtIndex:(NSUInteger)buttonIndex {
    NSLog(@"ButtonIndex: %d", buttonIndex);
    if (buttonIndex == 0) { // video 
        [self recordButtonPressed:nil];
    } else if (buttonIndex == 1) { //camera
        
    } else if (buttonIndex == 2) { // mic
        
    }
}

- (void) recordButtonPressed:(id)sender {
    OWCaptureViewController *captureVC = [[OWCaptureViewController alloc] init];
    [self presentViewController:captureVC animated:YES completion:^{
    }];
}


- (void) settingsButtonPressed:(id)sender {
    OWSettingsViewController *settingsView = [[OWSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsView animated:YES];
}



- (void) savedButtonPressed:(id)sender {
    OWRecordingListViewController *recordingListView = [[OWRecordingListViewController alloc] init];
    [self.navigationController pushViewController:recordingListView animated:YES];
}

- (void) watchButtonPressed:(id)sender {
    OWFeedType type = kOWFeedTypeFeed;
    NSString *feedString = FEATURED_STRING;
    [self pushFeedVCForFeedName:feedString type:type];
}

- (void) pushFeedVCForFeedName:(NSString*)feedName type:(OWFeedType)type {
    OWFeedViewController *feedVC = [[OWFeedViewController alloc] init];
    [feedVC didSelectFeedWithName:feedName type:type];
    [self.navigationController pushViewController:feedVC animated:YES];
}

- (void) localButtonPressed:(id)sender {
    OWFeedType type = kOWFeedTypeFeed;
    NSString *feedString = LOCAL_STRING;
    [self pushFeedVCForFeedName:feedString type:type];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[OWShareController sharedInstance] shareFromViewController:self];
    }
}

@end
