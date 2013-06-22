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
#import "OWStrings.h"
#import "OWMapAnnotation.h"
#import "OWMapViewController.h"

@interface OWMissionViewController ()

@end

@implementation OWMissionViewController
@synthesize mission, scrollView, imageView, titleLabel, blurbLabel, dashboardView, userView;
@synthesize imageContainerView, bannerView;

- (id)init
{
    self = [super init];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = [UIFont fontWithName:@"Palatino-Bold" size:23.0f];
        self.blurbLabel = [[UILabel alloc] init];
        self.blurbLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:20.0f];
        self.blurbLabel.backgroundColor = [UIColor clearColor];
        self.blurbLabel.numberOfLines = 0;
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.scrollView = [[UIScrollView alloc] init];
        self.userView = [[OWUserView alloc] initWithFrame:CGRectZero];
        
        self.dashboardView = [[OWDashboardView alloc] initWithFrame:CGRectZero];
        self.dashboardView.dashboardTableView.scrollEnabled = NO;
        self.imageContainerView = [[UIView alloc] init];
        imageContainerView.clipsToBounds = NO;
        imageContainerView.layer.masksToBounds = NO;
        [self.imageContainerView addSubview:imageView];
        [self.view addSubview:scrollView];
        [self.scrollView addSubview:titleLabel];
        [self.scrollView addSubview:blurbLabel];
        [self.scrollView addSubview:imageContainerView];
        [self.scrollView addSubview:dashboardView];
        [self.scrollView addSubview:userView];
        
        OWDashboardItem *videoItem = [[OWDashboardItem alloc] initWithTitle:BROADCAST_VIDEO_STRING image:[UIImage imageNamed:@"285-facetime.png"] target:self selector:@selector(recordButtonPressed:)];
        
        NSArray *mediaItems = @[videoItem];
        self.dashboardView.dashboardItems = @[mediaItems];

    }
    return self;
}

- (void) viewOnMap:(id)sender {
    OWMapAnnotation *annotation = [[OWMapAnnotation alloc] initWithCoordinate:mission.coordinate title:mission.title subtitle:mission.body];
    OWMapViewController *mapView = [[OWMapViewController alloc] init];
    mapView.annotation = annotation;
    [self.navigationController pushViewController:mapView animated:YES];
}

- (void) recordButtonPressed:(id)sender {
    OW_APP_DELEGATE.creationController.primaryTag = self.mission.primaryTag;
    [OW_APP_DELEGATE.creationController recordVideoFromViewController:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [OWUtilities stoneBackgroundPattern];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshFrames];
}

- (void) refreshFrames {
    CGFloat padding = 10.0f;
    CGFloat frameWidth = self.view.frame.size.width;
    CGFloat paddedWidth = frameWidth - padding * 2;
    
    
    self.imageView.frame = CGRectMake(0, 0, frameWidth, 200);
    self.imageContainerView.frame = self.imageView.frame;
    
    CGFloat bannerHeight = bannerView.imageView.image.size.height;
    
    self.bannerView.frame = CGRectMake(frameWidth, self.imageContainerView.frame.size.height - bannerHeight - padding, bannerView.imageView.image.size.width, bannerHeight);
    
    [OWUtilities applyShadowToView:imageContainerView];
    
    CGRect titleLabelFrame = [OWUtilities constrainedFrameForLabel:titleLabel width:paddedWidth origin:CGPointMake(padding, [OWUtilities bottomOfView:imageView] + padding)];
    self.titleLabel.frame = titleLabelFrame;
    
    self.userView.frame = CGRectMake(padding, [OWUtilities bottomOfView:titleLabel] + padding, paddedWidth, 65);
    
    CGRect blurbLabelFrame = [OWUtilities constrainedFrameForLabel:blurbLabel width:paddedWidth origin:CGPointMake(padding, [OWUtilities bottomOfView:userView] + padding)];
    self.blurbLabel.frame = blurbLabelFrame;
    
    self.dashboardView.frame = CGRectMake(0, [OWUtilities bottomOfView:blurbLabel] + padding, frameWidth, self.dashboardView.dashboardTableView.contentSize.height);
        
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [OWUtilities bottomOfView:dashboardView]);
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat bannerHeight = bannerView.imageView.image.size.height;
        CGFloat padding = 10.0f;
                
        self.bannerView.frame = CGRectMake(self.view.frame.size.width - bannerView.imageView.image.size.width, self.imageContainerView.frame.size.height - bannerHeight - padding, bannerView.imageView.image.size.width, bannerHeight);
    } completion:^(BOOL finished) {
        
    }];
    
    self.mission.viewed = @(YES);
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        [OWMission updateUnreadCount];
    }];
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
    self.title = [NSString stringWithFormat:@"#%@", mission.primaryTag];
    self.userView.user = mission.user;
    
    if (self.bannerView) {
        [bannerView removeFromSuperview];
    }

    UIImage *bannerImage = nil;
    NSString *text = nil;
    if (mission.usdValue > 0) {
        bannerImage = [UIImage imageNamed:@"side_banner_green.png"];
        text = [NSString stringWithFormat:@"$%.02f", mission.usdValue];
    } else {
        bannerImage = [UIImage imageNamed:@"side_banner_purple.png"];
        text = [NSString stringWithFormat:@"%d Karma", (int)mission.karmaValue];
    }

    self.bannerView = [[OWBannerView alloc] initWithFrame:CGRectZero bannerImage:bannerImage labelText:text];
    [self.scrollView addSubview:bannerView];
    
    if (mission.coordinate.latitude != 0.0f && mission.coordinate.longitude != 0.0f) {
        OWDashboardItem *viewOnMap = [[OWDashboardItem alloc] initWithTitle:VIEW_ON_MAP_STRING image:[UIImage imageNamed:@"193-location-arrow.png"] target:self selector:@selector(viewOnMap:)];
        
        NSArray *mapArray = @[viewOnMap];
        NSMutableArray *dashboardItems = [NSMutableArray arrayWithArray:self.dashboardView.dashboardItems];
        [dashboardItems insertObject:mapArray atIndex:0];
        self.dashboardView.dashboardItems = dashboardItems;
    }
}

@end
