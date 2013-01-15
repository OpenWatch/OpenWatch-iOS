//
//  OWMediaObjectViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/14/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWMediaObjectViewController.h"
#import "OWShareController.h"
#import "OWAccountAPIClient.h"
#import "OWStrings.h"

@interface OWMediaObjectViewController ()

@end

@implementation OWMediaObjectViewController
@synthesize mediaObjectID;

- (id)init
{
    self = [super init];
    if (self) {
        [self setupSharing];
    }
    return self;
}

- (void) shareButtonPressed:(id)sender {
    [[OWShareController sharedInstance] shareMediaObjectID:mediaObjectID fromViewController:self];
    [[OWAccountAPIClient sharedClient] hitMediaObject:self.mediaObjectID hitType:kHitTypeClick];
}

- (void) setupSharing {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SHARE_STRING style:UIBarButtonItemStyleBordered target:self action:@selector(shareButtonPressed:)];
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

@end
