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
#import "OWSettingsController.h"
#import "OWAccountAPIClient.h"
#import "OWMissionStatsView.h"

@interface OWMissionViewController ()

@end

@implementation OWMissionViewController
@synthesize mission, scrollView, imageView, titleLabel, blurbLabel;
@synthesize imageContainerView, bannerView, joinButton;
@synthesize mapButton, mediaButton, timeLeftLabel;
@synthesize statsView;

- (id)init
{
    self = [super init];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:23.0f];
        self.blurbLabel = [[UILabel alloc] init];
        self.blurbLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
        self.blurbLabel.backgroundColor = [UIColor clearColor];
        self.blurbLabel.numberOfLines = 0;
        self.timeLeftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLeftLabel.backgroundColor = [UIColor clearColor];
        self.timeLeftLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
        self.timeLeftLabel.textColor = [UIColor lightGrayColor];
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        imageView.layer.shouldRasterize = YES;
        imageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        self.scrollView = [[UIScrollView alloc] init];
        
        self.statsView = [[OWMissionStatsView alloc] init];
        
        self.joinButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeSuccess];
        
        [joinButton addTarget:self action:@selector(joinButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [joinButton setTitle:JOIN_STRING forState:UIControlStateNormal];
        
        self.mapButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeDefault];
        [self.mapButton addTarget:self action:@selector(viewOnMap:) forControlEvents:UIControlEventTouchUpInside];
        [self.mapButton setTitle:VIEW_ON_MAP_STRING forState:UIControlStateNormal];
        [self.mapButton addAwesomeIcon:FAIconMapMarker beforeTitle:YES];
        
        self.mediaButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeDefault];
        [self.mediaButton addTarget:self action:@selector(mediaButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.mediaButton setTitle:VIEW_MEDIA_STRING forState:UIControlStateNormal];
        [self.mediaButton addAwesomeIcon:FAIconCamera beforeTitle:YES];
        
        self.imageContainerView = [[UIView alloc] init];
        imageContainerView.clipsToBounds = NO;
        imageContainerView.layer.masksToBounds = NO;
        imageContainerView.layer.shouldRasterize = YES;
        imageContainerView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        [self.imageContainerView addSubview:imageView];
        [self.view addSubview:scrollView];
        [self.scrollView addSubview:joinButton];
        [self.scrollView addSubview:mapButton];
        [self.scrollView addSubview:mediaButton];
        [self.scrollView addSubview:titleLabel];
        [self.scrollView addSubview:blurbLabel];
        [self.scrollView addSubview:imageContainerView];
        [self.scrollView addSubview:timeLeftLabel];
        [self.scrollView addSubview:statsView];
    }
    return self;
}

- (void) viewOnMap:(id)sender {
    OWMapAnnotation *annotation = [[OWMapAnnotation alloc] initWithCoordinate:mission.coordinate title:mission.title subtitle:mission.body];
    OWMapViewController *mapView = [[OWMapViewController alloc] init];
    mapView.annotation = annotation;
    [self.navigationController pushViewController:mapView animated:YES];
}

- (void) joinButtonPressed:(id)sender {
    if (!self.mission.joined) {
        self.mission.joined = [NSDate date];
        [[OWAccountAPIClient sharedClient] postAction:@"joined" forMission:mission success:nil failure:nil retryCount:kOWAccountAPIClientDefaultRetryCount];
        [[Mixpanel sharedInstance] track:@"Joined Mission" properties:@{@"mission_id": mission.serverID}];
        [OWSettingsController sharedInstance].account.lastSelectedMission = mission;
    } else {
        [[OWAccountAPIClient sharedClient] postAction:@"left" forMission:mission success:nil failure:nil retryCount:kOWAccountAPIClientDefaultRetryCount];
        [[Mixpanel sharedInstance] track:@"Left Mission" properties:@{@"mission_id": mission.serverID}];
        self.mission.joined = nil;
        [OWSettingsController sharedInstance].account.lastSelectedMission = nil;
    }
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreAndWait];
    [self refreshJoinButtonState];
}

- (void) refreshJoinButtonState {
    if (self.mission.joined) {
        [self.joinButton setType:BButtonTypeDanger];
        [self.joinButton setTitle:LEAVE_STRING forState:UIControlStateNormal];
    } else {
        [self.joinButton setType:BButtonTypeSuccess];
        [self.joinButton setTitle:JOIN_STRING forState:UIControlStateNormal];
    }
}

- (void) mediaButtonPressed:(id)sender {
    OWFeedViewController *feedView = [[OWFeedViewController alloc] init];
    feedView.showBackButton = YES;
    [feedView didSelectFeedWithName:self.mission.primaryTag displayName:self.mission.primaryTag type:kOWFeedTypeTag];
    [self.navigationController pushViewController:feedView animated:YES];
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
    [[OWAccountAPIClient sharedClient] postAction:@"viewed_mission" forMission:mission success:nil failure:nil retryCount:kOWAccountAPIClientDefaultRetryCount];
    [[Mixpanel sharedInstance] track:@"Viewed Mission" properties:@{@"mission_id": mission.serverID}];
}

- (void) refreshFrames {
    CGFloat padding = 10.0f;
    CGFloat frameWidth = self.view.frame.size.width;
    CGFloat paddedWidth = frameWidth - padding * 2;
    
    self.imageView.frame = CGRectMake(0, 0, frameWidth, 200);
    self.imageContainerView.frame = self.imageView.frame;
    
    CGFloat bannerHeight = bannerView.imageView.image.size.height;
    
    self.bannerView.frame = CGRectMake(frameWidth, self.imageContainerView.frame.size.height - bannerHeight - padding, bannerView.imageView.image.size.width, bannerHeight);
    
    CGFloat statsViewHeight = 25;
    CGFloat statsViewWidth = 170;
    self.statsView.frame = CGRectMake(padding, self.imageContainerView.frame.size.height - statsViewHeight - padding, statsViewWidth, statsViewHeight);
    
    [OWUtilities applyShadowToView:imageContainerView];
    
    CGRect titleLabelFrame = [OWUtilities constrainedFrameForLabel:titleLabel width:paddedWidth origin:CGPointMake(padding, [OWUtilities bottomOfView:imageView] + padding)];
    self.titleLabel.frame = titleLabelFrame;
    
    self.timeLeftLabel.frame = CGRectMake(padding, [OWUtilities bottomOfView:titleLabel] + padding/2, paddedWidth, 17);

    CGRect joinButtonFrame = CGRectMake(padding, [OWUtilities bottomOfView:timeLeftLabel] + padding, paddedWidth, 45);
    self.joinButton.frame = joinButtonFrame;
    
    CGFloat buttonWidth = (paddedWidth - padding) / 2;
    CGFloat buttonHeight = 30.0;
    CGFloat buttonsYOrigin = [OWUtilities bottomOfView:joinButton] + padding;
    CGRect mapButtonFrame = CGRectMake(padding, buttonsYOrigin, buttonWidth, buttonHeight);
    self.mapButton.frame = mapButtonFrame;
    CGRect mediaButtonFrame = CGRectMake([OWUtilities rightOfView:mapButton] + padding, buttonsYOrigin, buttonWidth, buttonHeight);
    self.mediaButton.frame = mediaButtonFrame;
    
    CGRect blurbLabelFrame = [OWUtilities constrainedFrameForLabel:blurbLabel width:paddedWidth origin:CGPointMake(padding, [OWUtilities bottomOfView:mapButton] + padding)];
    self.blurbLabel.frame = blurbLabelFrame;
    
        
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [OWUtilities bottomOfView:blurbLabel] + padding);
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
    
    TTTTimeIntervalFormatter *timeLeftFormatter = [OWUtilities timeLeftIntervalFormatter];
    self.timeLeftLabel.text = [timeLeftFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:mission.expirationDate];
    
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
    
    if (self.bannerView) {
        [bannerView removeFromSuperview];
    }

    UIImage *bannerImage = nil;
    NSString *text = nil;
    if (mission.usdValue > 0) {
        bannerImage = [UIImage imageNamed:@"side_banner_green.png"];
        text = [NSString stringWithFormat:@"$%.02f", mission.usdValue];
    } else if (mission.karmaValue > 0) {
        bannerImage = [UIImage imageNamed:@"side_banner_purple.png"];
        text = [NSString stringWithFormat:@"%d Karma", (int)mission.karmaValue];
    }
    if (bannerImage) {
        self.bannerView = [[OWBannerView alloc] initWithFrame:CGRectZero bannerImage:bannerImage labelText:text];
        [self.scrollView addSubview:bannerView];
    }
    
    if (mission.coordinate.latitude != 0.0f && mission.coordinate.longitude != 0.0f) {
        self.mapButton.userInteractionEnabled = YES;
        self.mapButton.alpha = 1.0;
    } else {
        self.mapButton.userInteractionEnabled = NO;
        self.mapButton.alpha = 0.5;
    }
    [self refreshJoinButtonState];
    self.statsView.mission = mission;
}

@end
