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
#import "OWFeedSelectionViewController.h"
#import "OWInvestigationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "OWSettingsController.h"
#import "OWFeedViewController.h"
#import "OWDashboardItem.h"
#import "OWPhoto.h"

#define kActionBarHeight 70.0f


@interface OWDashboardViewController ()

@end

@implementation OWDashboardViewController
@synthesize onboardingView, dashboardView, imagePicker;

- (id)init
{
    self = [super init];
    if (self) {
        self.dashboardView = [[OWDashboardView alloc] initWithFrame:CGRectZero];
        OWDashboardItem *videoItem = [[OWDashboardItem alloc] initWithTitle:@"Broadcast Video" image:[UIImage imageNamed:@"285-facetime.png"] target:self selector:@selector(recordButtonPressed:)];
        OWDashboardItem *photoItem = [[OWDashboardItem alloc] initWithTitle:@"Take Photo" image:[UIImage imageNamed:@"86-camera.png"] target:self selector:@selector(photoButtonPressed:)];
        OWDashboardItem *audioItem = [[OWDashboardItem alloc] initWithTitle:@"Record Audio" image:[UIImage imageNamed:@"66-microphone.png"] target:self selector:@selector(comingSoon:)];
        
        OWDashboardItem *topStories = [[OWDashboardItem alloc] initWithTitle:@"Top Stories" image:[UIImage imageNamed:@"28-star.png"] target:self selector:@selector(feedButtonPressed:)];
        OWDashboardItem *yourMedia = [[OWDashboardItem alloc] initWithTitle:@"Your Media" image:[UIImage imageNamed:@"160-voicemail-2.png"] target:self selector:@selector(yourMediaPressed:)];
        OWDashboardItem *settings = [[OWDashboardItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"19-gear.png"] target:self selector:@selector(settingsButtonPressed:)];
        
        NSArray *topItems = @[videoItem, photoItem, audioItem];
        NSArray *bottonItems = @[topStories, yourMedia, settings];
        NSArray *dashboardItems = @[topItems, bottonItems];
        dashboardView.dashboardItems = dashboardItems;        
    }
    return self;
}

- (void) photoButtonPressed:(id)sender {
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    BOOL canTakePhoto = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (canTakePhoto) {
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Available" message:@"Sorry, this device can't take photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}



- (void) feedButtonPressed:(id)sender {
    OWFeedViewController *feedVC = [[OWFeedViewController alloc] init];
    [feedVC didSelectFeedWithName:@"Top Stories" type:kOWFeedTypeFrontPage];
    [self.navigationController pushViewController:feedVC animated:YES];
}

- (void) recordButtonPressed:(id)sender {
    OWCaptureViewController *captureVC = [[OWCaptureViewController alloc] init];
    [self presentViewController:captureVC animated:YES completion:^{
    }];
}

- (void) yourMediaPressed:(id)sender {
    OWRecordingListViewController *recordingListVC = [[OWRecordingListViewController alloc] init];
    [self.navigationController pushViewController:recordingListVC animated:YES];
}

- (void) settingsButtonPressed:(id) sender {
    OWSettingsViewController *settingsVC = [[OWSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void) comingSoon:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coming soon!" message:@"Sorry I haven't written that part yet. Check back later!" delegate:nil cancelButtonTitle:@"Cool" otherButtonTitles:nil];
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:dashboardView];
    
    self.view.backgroundColor = [OWUtilities stoneBackgroundPattern];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openwatch.png"]];
    imageView.frame = CGRectMake(0, 0, 140, 25);
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
    
    self.dashboardView.frame = self.view.bounds;
    
    OWAccount *account = [OWSettingsController sharedInstance].account;

    if ((!account.hasCompletedOnboarding && !self.onboardingView)) {
        self.onboardingView = [[OWOnboardingView alloc] initWithFrame:self.view.bounds];
        self.onboardingView.delegate = self;
        UIImage *firstImage = [UIImage imageNamed:@"ow_space1.jpg"];
        UIImage *secondImage = [UIImage imageNamed:@"ow_space2.jpg"];
        
        self.onboardingView.images = @[firstImage, secondImage];
        [self.view addSubview:onboardingView];
    }
}


- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[OWShareController sharedInstance] shareFromViewController:self];
    }
}

- (void) onboardingViewDidComplete:(OWOnboardingView *)onboardingView {
    OWAccount *account = [OWSettingsController sharedInstance].account;
    account.hasCompletedOnboarding = YES;
    [UIView animateWithDuration:2.0 animations:^{
        self.onboardingView.layer.opacity = 0.0f;
    } completion:^(BOOL finished) {
        [self.onboardingView removeFromSuperview];
        self.onboardingView = nil;
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.imagePicker dismissViewControllerAnimated:YES completion:^{
        self.imagePicker = nil;
    }];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    OWPhoto *photo = [OWPhoto photoWithImage:image];
    NSLog(@"photo created: %@", photo.description);
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:^{
        self.imagePicker = nil;
    }];
}

@end
