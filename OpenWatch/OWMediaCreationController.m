//
//  OWMediaCreationController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMediaCreationController.h"
#import "OWPhoto.h"
#import "OWAppDelegate.h"
#import "OWAccountAPIClient.h"

@implementation OWMediaCreationController
@synthesize audioRecorder, imagePicker, editController, presentingViewController;
@synthesize primaryTag;

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    OWPhoto *photo = [OWPhoto photoWithImage:image];
    photo.firstPostedDate = [NSDate date];
    OWLocationController *locationController = [OWLocationController sharedInstance];
    photo.endLocation = locationController.currentLocation;
    [locationController stop];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreAndWait];
    
    self.editController.objectID = photo.objectID; // this smells
    
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
    
    [presentingViewController.navigationController popToRootViewControllerAnimated:NO];
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
    [presentingViewController.navigationController popToRootViewControllerAnimated:NO];
}

- (void) captureViewController:(OWCaptureViewController *)captureViewController didFinishRecording:(OWLocalRecording *)recording {
    self.editController.objectID = recording.objectID;
    [captureViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

- (void) captureViewControllerDidCancel:(OWCaptureViewController *)captureViewController{
    [presentingViewController.navigationController popToRootViewControllerAnimated:NO];
}

- (void) recordAudioFromViewController:(UIViewController *)viewController {
    self.presentingViewController = viewController;
    self.audioRecorder = [[OWAudioRecordingViewController alloc] init];
    audioRecorder.delegate = self;
    OWLocationController *locationController = [OWLocationController sharedInstance];
    [locationController startWithDelegate:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:audioRecorder];
    [presentingViewController presentViewController:navController animated:YES completion:^{
        [self pushEditView];
    }];
}

- (void) recordVideoFromViewController:(UIViewController *)viewController {
    self.presentingViewController = viewController;
    OWCaptureViewController *captureVC = [[OWCaptureViewController alloc] init];
    captureVC.delegate = self;
    [presentingViewController presentViewController:captureVC animated:YES completion:^{
        [self pushEditView];
    }];
}

- (void) pushEditView {
    self.editController = [[OWLocalMediaEditViewController alloc] init];
    self.editController.primaryTag = self.primaryTag;
    self.editController.showingAfterCapture = YES;
    [presentingViewController.navigationController pushViewController:editController animated:YES];
}

- (void) takePhotoFromViewController:(UIViewController *)viewController {
    self.presentingViewController = viewController;
    OWLocationController *locationController = [OWLocationController sharedInstance];
    [locationController startWithDelegate:nil];
    
    if (!self.imagePicker) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    BOOL canTakePhoto = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (canTakePhoto) {
        [OW_APP_DELEGATE.dashboardViewController presentViewController:imagePicker animated:YES completion:^{
            [self pushEditView];
        }];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Available" message:@"Sorry, this device can't take photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


@end
