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
#import "MBProgressHUD.h"
#import "OWUtilities.h"


@interface OWMissionViewController ()

@end

@implementation OWMissionViewController
@synthesize mission, scrollView, imageView, titleLabel, blurbLabel, dashboardView, userView, bountyLabel;

- (id)init
{
    self = [super init];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.font = [UIFont fontWithName:@"Palatino-Bold" size:23.0f];
        self.blurbLabel = [[UILabel alloc] init];
        self.blurbLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:20.0f];
        self.blurbLabel.backgroundColor = [UIColor clearColor];
        self.blurbLabel.numberOfLines = 0;
        self.bountyLabel = [[UILabel alloc] init];
        self.bountyLabel.backgroundColor = [UIColor clearColor];
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.scrollView = [[UIScrollView alloc] init];
        self.userView = [[OWUserView alloc] initWithFrame:CGRectZero];
        
        self.dashboardView = [[OWDashboardView alloc] initWithFrame:CGRectZero];
        self.dashboardView.dashboardTableView.scrollEnabled = NO;
        [self.view addSubview:scrollView];
        [self.scrollView addSubview:titleLabel];
        [self.scrollView addSubview:blurbLabel];
        [self.scrollView addSubview:imageView];
        [self.scrollView addSubview:dashboardView];
        [self.scrollView addSubview:bountyLabel];
        [self.scrollView addSubview:userView];
        
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
    CGFloat padding = 10.0f;
    CGFloat frameWidth = self.view.frame.size.width;
    CGFloat paddedWidth = frameWidth - padding * 2;

    self.imageView.frame = CGRectMake(0, 0, frameWidth, 200);
    self.titleLabel.frame = CGRectMake(padding, [OWUtilities bottomOfView:imageView] + padding/2, paddedWidth, 50);
    self.userView.frame = CGRectMake(padding, [OWUtilities bottomOfView:titleLabel] + padding/2, paddedWidth, 65);
    self.blurbLabel.frame = CGRectMake(padding, [OWUtilities bottomOfView:userView] + padding/2, paddedWidth, 120);
    self.bountyLabel.frame = CGRectMake(padding, [OWUtilities bottomOfView:blurbLabel] + padding/2, 50, 25);
    self.dashboardView.frame = CGRectMake(0, [OWUtilities bottomOfView:bountyLabel] + padding/2, frameWidth, 120);

    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [OWUtilities bottomOfView:dashboardView]);
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
    NSURLRequest *request = [NSURLRequest requestWithURL:mission.mediaURL];
    
    __weak UIImageView *weakImageView = self.imageView;
    [MBProgressHUD showHUDAddedTo:self.imageView animated:YES];
    [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakImageView.image = image;
        [MBProgressHUD hideAllHUDsForView:weakImageView animated:YES];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Error loading mission image: %@", error.userInfo);
        [MBProgressHUD hideAllHUDsForView:weakImageView animated:YES];
    }];
    self.bountyLabel.text = [NSString stringWithFormat:@"$%.2f", mission.usdValue];
    self.title = [NSString stringWithFormat:@"#%@", mission.primaryTag];
    self.userView.user = mission.user;
}

@end
