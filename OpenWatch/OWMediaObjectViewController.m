//
//  OWMediaObjectViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/14/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWMediaObjectViewController.h"
#import "OWAccountAPIClient.h"
#import "OWStrings.h"
#import "OWUtilities.h"
#import "OWMediaObject.h"
#import "OWSocialController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "OWAppDelegate.h"

@interface OWMediaObjectViewController ()

@end

@implementation OWMediaObjectViewController
@synthesize mediaObjectID, shareButton, recordButton;

- (id)init
{
    self = [super init];
    if (self) {
        self.shareButton = [OWUtilities barItemWithImage:[UIImage imageNamed:@"212-action2.png"] target:self action:@selector(shareButtonPressed:)];
        self.recordButton = [OWUtilities barItemWithImage:[UIImage imageNamed:@"285-facetime-red.png"] target:self action:@selector(startRecording:)];
        self.navigationItem.rightBarButtonItems = @[recordButton, shareButton];
    }
    return self;
}

- (void) shareButtonPressed:(id)sender {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSError *error = nil;
    OWMediaObject *mediaObject = (OWMediaObject*)[context existingObjectWithID:self.mediaObjectID error:&error];
    if (error) {
        NSLog(@"Error fetching object: %@", error.userInfo);
    }
        
    [OWSocialController shareMediaObject:mediaObject fromViewController:self];
    
    [[OWAccountAPIClient sharedClient] hitMediaObject:self.mediaObjectID hitType:kHitTypeClick];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    mediaObjectID = newMediaObjectID;
    [[OWAccountAPIClient sharedClient] hitMediaObject:mediaObjectID hitType:kHitTypeView];
}

- (void) startRecording:(id)sender {
    [OW_APP_DELEGATE.creationController recordVideoFromViewController:self];
}

@end
