//
//  OWDashboardViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWDashboardViewController.h"
#import "OWUtilities.h"
#import "OWCaptureViewController.h"
#import "OWAccountAPIClient.h"
#import "OWLoginViewController.h"
#import "OWSettingsViewController.h"
#import "OWLocalMediaObjectListViewController.h"
#import "OWStrings.h"
#import "OWFeedViewController.h"
#import "OWFeedSelectionViewController.h"
#import "OWInvestigationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "OWSettingsController.h"
#import "OWFeedViewController.h"
#import "OWDashboardItem.h"
#import "OWPhoto.h"
#import "OWLocationController.h"
#import "OWLocalMediaEditViewController.h"
#import "OWAppDelegate.h"
#import "OWShareController.h"
#import "UserVoice.h"
#import "OWStyleSheet.h"
#import "OWAPIKeys.h"
#import "OWConstants.h"
#import "OWMissionListViewController.h"
#import "OWMission.h"

#define kActionBarHeight 70.0f


@interface OWDashboardViewController ()

@end

@implementation OWDashboardViewController
@synthesize onboardingView, dashboardView, imagePicker, audioRecorder, editController;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.dashboardView = [[OWDashboardView alloc] initWithFrame:CGRectZero];
        OWDashboardItem *videoItem = [[OWDashboardItem alloc] initWithTitle:@"Broadcast Video" image:[UIImage imageNamed:@"285-facetime.png"] target:self selector:@selector(recordButtonPressed:)];
        OWDashboardItem *photoItem = [[OWDashboardItem alloc] initWithTitle:@"Take Photo" image:[UIImage imageNamed:@"86-camera.png"] target:self selector:@selector(photoButtonPressed:)];
        //OWDashboardItem *audioItem = [[OWDashboardItem alloc] initWithTitle:@"Record Audio" image:[UIImage imageNamed:@"66-microphone.png"] target:self selector:@selector(audioButtonPressed:)];
        
        OWDashboardItem *topStories = [[OWDashboardItem alloc] initWithTitle:@"Top Stories" image:[UIImage imageNamed:@"28-star.png"] target:self selector:@selector(feedButtonPressed:)];
        OWDashboardItem *local = [[OWDashboardItem alloc] initWithTitle:@"Local Feed" image:[UIImage imageNamed:@"193-location-arrow.png"] target:self selector:@selector(localFeedButtonPressed:)];
        OWDashboardItem *yourMedia = [[OWDashboardItem alloc] initWithTitle:@"Your Media" image:[UIImage imageNamed:@"160-voicemail-2.png"] target:self selector:@selector(yourMediaPressed:)];
        
        OWDashboardItem *feedback = [[OWDashboardItem alloc] initWithTitle:@"Send Feedback" image:[UIImage imageNamed:@"29-heart.png"] target:self selector:@selector(feedbackButtonPressed:)];
        OWDashboardItem *settings = [[OWDashboardItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"19-gear.png"] target:self selector:@selector(settingsButtonPressed:)];
        
        OWDashboardItem *missions = [[OWDashboardItem alloc] initWithTitle:@"Missions" image:[UIImage imageNamed:@"108-badge.png"] target:self selector:@selector(missionsButtonPressed:)];
        
        NSArray *topItems = @[videoItem, photoItem];
        NSArray *middleItems = @[topStories, local, yourMedia];
        NSArray *bottonItems = @[feedback, settings];
        NSArray *dashboardItems = @[@[missions], topItems, middleItems, bottonItems];
        dashboardView.dashboardItems = dashboardItems;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedAccountPermissionsErrorNotification:) name:kAccountPermissionsError object:nil];
    }
    return self;
}

- (void) receivedAccountPermissionsErrorNotification:(NSNotification*)notification {
    NSLog(@"%@ received", kAccountPermissionsError);
    [TestFlight passCheckpoint:kAccountPermissionsError];
    [self.navigationController popToRootViewControllerAnimated:YES];
    OWLoginViewController *loginViewController = [[OWLoginViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    loginViewController.showCancelButton = NO;
    [self presentViewController:navController animated:YES completion:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"It looks like your session has expired. Please log in again. Sorry!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}


- (void) missionsButtonPressed:(id)sender {
    OWMissionListViewController *missionList = [[OWMissionListViewController alloc] init];
    
    NSArray *missions = [OWMission MR_findAll];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    if (missions.count == 0) {
        for (int i = 0; i < 5; i++) {
            OWMission *mission = [OWMission MR_createInContext:context];
            mission.title = [NSString stringWithFormat:@"Mission %d", i];
            mission.blurb = [NSString stringWithFormat:@"This is such a great mission (%d).", i];
            mission.bounty = @(i+1);
        }
        [context MR_saveToPersistentStoreAndWait];
    }
    
    [self.navigationController pushViewController:missionList animated:YES];
}


- (void) feedbackButtonPressed:(id)sender {
    UVConfig *config = [UVConfig configWithSite:@"openwatch.uservoice.com"
                                         andKey:USERVOICE_API_KEY
                                      andSecret:USERVOICE_API_SECRET];
    [UVStyleSheet setStyleSheet:[[OWStyleSheet alloc] init]];
    [UserVoice presentUserVoiceInterfaceForParentViewController:self andConfig:config];
}

- (void) audioButtonPressed:(id)sender {
    self.audioRecorder = [[OWAudioRecordingViewController alloc] init];
    audioRecorder.delegate = self;
    OWLocationController *locationController = [OWLocationController sharedInstance];
    [locationController startWithDelegate:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:audioRecorder];
    [self presentViewController:navController animated:YES completion:^{
        [self pushEditView];
    }];
}

- (void) recordButtonPressed:(id)sender {
    OWCaptureViewController *captureVC = [[OWCaptureViewController alloc] init];
    captureVC.delegate = self;
    [self presentViewController:captureVC animated:YES completion:^{
        [self pushEditView];
    }];
}

- (void) pushEditView {
    self.editController = [[OWLocalMediaEditViewController alloc] init];
    self.editController.showingAfterCapture = YES;
    [self.navigationController pushViewController:editController animated:YES];
}

- (void) photoButtonPressed:(id)sender {
    OWLocationController *locationController = [OWLocationController sharedInstance];
    [locationController startWithDelegate:nil];
    
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    BOOL canTakePhoto = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (canTakePhoto) {
        [self presentViewController:imagePicker animated:YES completion:^{
            [self pushEditView];
        }];
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

- (void) localFeedButtonPressed:(id)sender {
    OWFeedViewController *feedVC = [[OWFeedViewController alloc] init];
    [feedVC didSelectFeedWithName:@"Local" type:kOWFeedTypeFeed];
    [self.navigationController pushViewController:feedVC animated:YES];
}




- (void) yourMediaPressed:(id)sender {
    OWLocalMediaObjectListViewController *recordingListVC = [[OWLocalMediaObjectListViewController alloc] init];
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
    [self updateUserAccountInformation];
    
    self.view.backgroundColor = [OWUtilities stoneBackgroundPattern];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openwatch.png"]];
    imageView.frame = CGRectMake(0, 0, 140, 25);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGFloat navigationBarHeightHack = 0.0f;
    
    if (self.navigationController.navigationBarHidden) {
        navigationBarHeightHack = self.navigationController.navigationBar.frame.size.height;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    
    self.dashboardView.frame = self.view.bounds;
    
    OWAccount *account = [OWSettingsController sharedInstance].account;

    if (!account.hasCompletedOnboarding && !self.onboardingView) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeightHack);
        self.onboardingView = [[OWOnboardingView alloc] initWithFrame:frame];
        self.onboardingView.delegate = self;
        //self.onboardingView.frame = frame;
        [self.view addSubview:onboardingView];
    }
}

- (void) updateUserAccountInformation {
    OWAccount *account = [OWSettingsController sharedInstance].account;
    if (!account.isLoggedIn) {
        return;
    }
    [[OWAccountAPIClient sharedClient] updateUserSecretAgentStatus:account.secretAgentEnabled];
    if (!account.secretAgentEnabled) {
        return;
    }
    [[OWLocationController sharedInstance] startWithDelegate:self];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void) locationUpdated:(CLLocation *)location {
    OWLocationController *locationController = [OWLocationController sharedInstance];
    [locationController stop];
    OWAccount *account = [OWSettingsController sharedInstance].account;
    if (account.secretAgentEnabled) {
        [[OWAccountAPIClient sharedClient] updateUserLocation:location];
    }
}

- (void) onboardingViewDidComplete:(OWOnboardingView *)ow {
    OWAccount *account = [OWSettingsController sharedInstance].account;
    account.hasCompletedOnboarding = YES;
    account.secretAgentEnabled = onboardingView.agentSwitch.on;
    [self updateUserAccountInformation];
    [UIView animateWithDuration:2.0 animations:^{
        self.onboardingView.layer.opacity = 0.0f;
    } completion:^(BOOL finished) {
        [self.onboardingView removeFromSuperview];
        self.onboardingView = nil;
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    OWPhoto *photo = [OWPhoto photoWithImage:image];
    photo.firstPostedDate = [NSDate date];
    OWLocationController *locationController = [OWLocationController sharedInstance];
    photo.endLocation = locationController.currentLocation;
    [locationController stop];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreAndWait];
    
    self.editController.objectID = photo.objectID;
    
    [[OWAccountAPIClient sharedClient] postObjectWithUUID:photo.uuid objectClass:photo.class success:nil failure:nil];

    [self.imagePicker dismissViewControllerAnimated:YES completion:^{
        self.imagePicker = nil;
    }];
    
    NSLog(@"photo created: %@", photo.description);
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    OWLocationController *locationController = [OWLocationController sharedInstance];
    [locationController stop];
    [self.imagePicker dismissViewControllerAnimated:YES completion:^{
        self.imagePicker = nil;
    }];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void) recordingViewController:(OWAudioRecordingViewController *)recordingViewController didFinishRecording:(OWAudio *)audio {
    OWLocationController *locationController = [OWLocationController sharedInstance];
    [locationController stop];
    audio.firstPostedDate = [NSDate date];
    audio.endLocation = locationController.currentLocation;
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreAndWait];
    
    self.editController.objectID = audio.objectID;

    
    [[OWAccountAPIClient sharedClient] postObjectWithUUID:audio.uuid objectClass:audio.class success:nil failure:nil];
    
    [self.audioRecorder dismissViewControllerAnimated:YES completion:^{
        self.audioRecorder = nil;
    }];
}

- (void) recordingViewControllerDidCancel:(OWAudioRecordingViewController *)recordingViewController {
    OWLocationController *locationController = [OWLocationController sharedInstance];
    [locationController stop];
    [self.audioRecorder dismissViewControllerAnimated:YES completion:^{
        self.audioRecorder = nil;
    }];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void) captureViewController:(OWCaptureViewController *)captureViewController didFinishRecording:(OWLocalRecording *)recording {
    self.editController.objectID = recording.objectID;
    [captureViewController dismissViewControllerAnimated:YES completion:^{
         
     }];
    
}

- (void) captureViewControllerDidCancel:(OWCaptureViewController *)captureViewController{
    [self.navigationController popToRootViewControllerAnimated:NO];
}


@end
