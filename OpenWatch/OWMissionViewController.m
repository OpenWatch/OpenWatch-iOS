//
//  OWMissionViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/29/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMissionViewController.h"
#import "OWDashboardItem.h"
#import "OWAppDelegate.h"
#import "UIImageView+AFNetworking.h"

@interface OWMissionViewController ()

@end

@implementation OWMissionViewController
@synthesize mission, scrollView, imageView, titleLabel, blurbLabel, dashboardView;

- (id)init
{
    self = [super init];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.blurbLabel = [[UILabel alloc] init];
        self.bountyLabel = [[UILabel alloc] init];
        self.imageView = [[UIImageView alloc] init];
        self.scrollView = [[UIScrollView alloc] init];
        
        self.dashboardView = [[OWDashboardView alloc] initWithFrame:CGRectZero];
        self.dashboardView.dashboardTableView.scrollEnabled = NO;
        [self.view addSubview:scrollView];
        [self.scrollView addSubview:titleLabel];
        [self.scrollView addSubview:blurbLabel];
        [self.scrollView addSubview:imageView];
        [self.scrollView addSubview:dashboardView];
        
        OWDashboardItem *videoItem = [[OWDashboardItem alloc] initWithTitle:@"Broadcast Video" image:[UIImage imageNamed:@"285-facetime.png"] target:self selector:@selector(recordButtonPressed:)];
        OWDashboardItem *photoItem = [[OWDashboardItem alloc] initWithTitle:@"Take Photo" image:[UIImage imageNamed:@"86-camera.png"] target:self selector:@selector(photoButtonPressed:)];
        //OWDashboardItem *audioItem = [[OWDashboardItem alloc] initWithTitle:@"Record Audio" image:[UIImage imageNamed:@"66-microphone.png"] target:self selector:@selector(audioButtonPressed:)];
        NSArray *mediaItems = @[photoItem, videoItem];
        self.dashboardView.dashboardItems = @[mediaItems];

    }
    return self;
}

- (void) recordButtonPressed:(id)sender {
    OW_APP_DELEGATE.creationController.primaryTag = self.mission.primaryTag;
    [OW_APP_DELEGATE.creationController recordVideoFromViewController:self];
}

- (void) photoButtonPressed:(id)sender {
    OW_APP_DELEGATE.creationController.primaryTag = self.mission.primaryTag;
    [OW_APP_DELEGATE.creationController takePhotoFromViewController:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
    self.titleLabel.frame = CGRectMake(0, 100, 300, 50);
    self.blurbLabel.frame = CGRectMake(0, 150, 300, 50);
    self.bountyLabel.frame = CGRectMake(0, 300, 50, 25);
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 600);
    self.dashboardView.frame = CGRectMake(0, 200, self.view.frame.size.width, 120);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setMediaObjectID:(NSManagedObjectID *)mediaObjectID {
    [super setMediaObjectID:mediaObjectID];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    self.mission = (OWMission*)[context existingObjectWithID:mediaObjectID error:nil];
    self.titleLabel.text = mission.title;
    self.blurbLabel.text = mission.body;
    [self.imageView setImageWithURL:mission.thumbnailURL placeholderImage:nil];
    self.bountyLabel.text = [NSString stringWithFormat:@"$%.2f", mission.usdValue];
    self.title = [NSString stringWithFormat:@"#%@", mission.primaryTag];
}

@end
