//
//  OWRecordingInfoViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/26/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWRecordingInfoViewController.h"
#import "OWStrings.h"
#import "OWCaptureAPIClient.h"
#import "OWAccountAPIClient.h"
#import "OWMapAnnotation.h"
#import "OWRecordingController.h"
#import "OWUtilities.h"
#import "OWTallyView.h"
#import "UIImageView+AFNetworking.h"
#import "QuartzCore/CALayer.h"
#import "OWTag.h"
#import "OWLocalMediaObject.h"
#import "OWLocalMediaController.h"

#define PADDING 10.0f

@interface OWRecordingInfoViewController ()
@end

@implementation OWRecordingInfoViewController
@synthesize mapView, previewView, centerCoordinate, scrollView;
@synthesize titleLabel, segmentedControl;
@synthesize infoView, descriptionTextView, profileImageView, tallyView;
@synthesize usernameLabel, tagList;
@synthesize toolbar;

- (id) init {
    if (self = [super init]) {
        self.view.backgroundColor = [OWUtilities stoneBackgroundPattern];
        [self setupScrollView];
        [self setupMapView];
        [self setupSegmentedControl];
        [self setupDescriptionView];
        [self setupInfoView];
        [self setupTagList];
        [self setupMoviePlayer];
        self.title = INFO_STRING;
    }
    return self;
}

- (void) setupTagList {
    self.tagList = [[DWTagList alloc] init];
    self.tagList.delegate = self;
    [self.scrollView addSubview:tagList];
}

- (void) refreshTagsForMediaObject:(OWLocalMediaObject*)mediaObject {
    NSSet *tagSet = mediaObject.tags;
    NSMutableArray *tagNameArray = [[NSMutableArray alloc] initWithCapacity:tagSet.count];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *tagObjectArray = [tagSet sortedArrayUsingDescriptors:@[sortDescriptor]];
    for (OWTag *tag in tagObjectArray) {
        [tagNameArray addObject:tag.name];
    }
    [tagList setTags:tagNameArray];
}

- (void) selectedTagName:(NSString *)tagName atIndex:(NSUInteger)index {
    NSLog(@"selected: %d %@", index, tagName);
}


- (void) setupInfoView {
    self.infoView = [[UIView alloc] init];
    [self.scrollView addSubview:infoView];
    
    self.titleLabel = [[UILabel alloc] init];
    [self.infoView addSubview:titleLabel];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    self.profileImageView = [[UIImageView alloc] init];
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    /*profileImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    profileImageView.layer.shadowOffset = CGSizeMake(0, 1);
    profileImageView.layer.shadowOpacity = 1;
    profileImageView.layer.shadowRadius = 3.0;
     */
    profileImageView.layer.cornerRadius = 5;
    profileImageView.layer.shouldRasterize = YES;
    profileImageView.clipsToBounds = YES;
    [self.infoView addSubview:profileImageView];
    
    self.usernameLabel = [[UILabel alloc] init];
    [self.infoView addSubview:usernameLabel];
    self.usernameLabel.backgroundColor = [UIColor clearColor];
    
    CGFloat width = 125.0f;
    CGFloat height = 20.0f;
    self.tallyView = [[OWTallyView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self.infoView addSubview:tallyView];
}

- (void) setupDescriptionView {
    self.descriptionTextView = [[UITextView alloc] init];
    self.descriptionTextView.backgroundColor = [UIColor clearColor];
    self.descriptionTextView.editable = NO;
    self.descriptionTextView.font = [UIFont systemFontOfSize:16.0f];
    [self.scrollView addSubview:descriptionTextView];
}

- (void) setupMoviePlayer {
    self.previewView = [[OWPreviewView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:previewView];
}

- (void) setupSegmentedControl {
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[INFO_STRING, DESCRIPTION_STRING, MAP_STRING]];
    self.segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segmentedControl.tintColor = [OWUtilities navigationBarColor];
    [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    self.toolbar.tintColor = [OWUtilities navigationBarColor];
    UIBarButtonItem *barControl = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbar.items = @[flexibleSpace, barControl, flexibleSpace];
    [self.view addSubview:toolbar];
    [OWUtilities applyShadowToView:toolbar];
    //toolbar.layer.masksToBounds = NO;
}

- (void) segmentedControlValueChanged:(id)sender {
    CGPoint offset = CGPointMake(self.segmentedControl.selectedSegmentIndex * self.view.frame.size.width, 0);
    [scrollView setContentOffset:offset animated:YES];
}

- (void) setupScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.scrollEnabled = NO; // why doesnt this work?
    //self.scrollView.userInteractionEnabled = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.view addSubview:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)theScrollView {
    self.segmentedControl.selectedSegmentIndex = self.scrollView.contentOffset.x / self.view.frame.size.width;
}

- (void) setupMapView {
    if (mapView) {
        [mapView removeFromSuperview];
    }
    self.mapView = [[MKMapView alloc] init];
    mapView.delegate = self;
    [self.scrollView addSubview:mapView];
}


- (MKAnnotationView*) mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *pinReuseIdentifier = @"pinReuseIdentifier";
    OWMapAnnotation *mapAnnotation = (OWMapAnnotation*)annotation;
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pinReuseIdentifier];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:mapAnnotation reuseIdentifier:pinReuseIdentifier];
    }
    if (mapAnnotation.isStartLocation) {
        pinView.pinColor = MKPinAnnotationColorGreen;
    } else {
        pinView.pinColor = MKPinAnnotationColorRed;
    }
    return pinView;
}



- (void) refreshFrames {
    CGFloat moviePlayerYOrigin = 0.0f;
    CGFloat moviePlayerHeight = 240.0f;
    CGFloat frameWidth = self.view.frame.size.width;
    CGFloat frameHeight = self.view.frame.size.height;
    previewView.frame = CGRectMake(0, moviePlayerYOrigin, frameWidth, [OWPreviewView heightForWidth:frameWidth]);
    self.toolbar.frame = CGRectMake(0, moviePlayerHeight, frameWidth , 40.0f);
    CGFloat scrollViewYOrigin = [OWUtilities bottomOfView:toolbar];
    CGFloat scrollViewHeight = frameHeight-scrollViewYOrigin;
    self.scrollView.frame = CGRectMake(0, scrollViewYOrigin, frameWidth, scrollViewHeight);
    self.scrollView.contentSize = CGSizeMake(frameWidth * 3, scrollViewHeight);
    
    
    self.infoView.frame = CGRectMake(0, 0, frameWidth, scrollViewHeight);
    CGSize tagListSize = self.tagList.fittedSize;
    CGFloat xMargin = floorf((frameWidth - tagListSize.width) / 2);
    CGFloat yMargin = floorf((scrollViewHeight - tagListSize.height) / 2);
    self.tagList.frame = CGRectMake(frameWidth + xMargin, yMargin, frameWidth - xMargin, scrollViewHeight - yMargin);
    self.descriptionTextView.frame = CGRectMake(frameWidth, 0, frameWidth, scrollViewHeight);
    self.mapView.frame = CGRectMake(frameWidth*2, 0, frameWidth, scrollViewHeight);
    [self setFramesForInfoView];
}

- (void) setFramesForInfoView {
    CGFloat topMargin = 10.0f;
    self.profileImageView.frame = CGRectMake(30, topMargin, 100, 100);
    self.usernameLabel.frame = CGRectMake(30, [OWUtilities bottomOfView:profileImageView], 100, 20);
    
    self.titleLabel.frame = CGRectMake([OWUtilities rightOfView:profileImageView] + PADDING, topMargin + 10, 100, 50);
    self.tallyView.frame = CGRectMake([OWUtilities rightOfView:profileImageView] + PADDING, [OWUtilities bottomOfView:titleLabel], self.tallyView.frame.size.width, self.tallyView.frame.size.height);
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshFrames];
    [TestFlight passCheckpoint:VIEW_RECORDING_CHECKPOINT];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    [super setMediaObjectID:newMediaObjectID];

    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:self.mediaObjectID];
    NSURL *mediaURL = nil;
    if (mediaObject.localMediaPath.length > 0) {
        mediaURL = mediaObject.localMediaURL;
    } else if (mediaObject.remoteMediaURLString.length > 0) {
        mediaURL = mediaObject.remoteMediaURL;
    }
    self.previewView.objectID = self.mediaObjectID;
    
    [self refreshFields];
    [self refreshFrames];
    [self refreshMapParameters];
    
    [[OWAccountAPIClient sharedClient] getObjectWithUUID:mediaObject.uuid objectClass:[mediaObject class] success:^(NSManagedObjectID *objectID) {
        OWLocalMediaObject *newMediaObject = [OWLocalMediaController localMediaObjectForObjectID:self.mediaObjectID];
        self.previewView.objectID = objectID;
        [self refreshMapParameters];
        [self refreshFields];
        [self refreshFrames];
        [TestFlight passCheckpoint:VIEW_RECORDING_ID_CHECKPOINT([newMediaObject.serverID intValue])];
    } failure:^(NSString *reason) {
        NSLog(@"failure to fetch recording details: %@", reason);
    } retryCount:kOWAccountAPIClientDefaultRetryCount];
}


- (void) refreshMapParameters {
    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:self.mediaObjectID];
    CLLocation *end = mediaObject.endLocation;
    if (end) {
        self.centerCoordinate = end.coordinate;
    }
    
    [mapView removeAnnotations:[mapView annotations]];
    if (mediaObject.endLocation) {
        OWMapAnnotation *endAnnotation = [[OWMapAnnotation alloc] initWithCoordinate:mediaObject.endLocation.coordinate title:END_STRING subtitle:nil];
        [mapView addAnnotation:endAnnotation];
    }
    if (CLLocationCoordinate2DIsValid(centerCoordinate)) {
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(centerCoordinate, 1000, 1000) animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.scrollEnabled = YES;
}

- (void) refreshFields {
    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:self.mediaObjectID];
    if (!mediaObject) {
        return;
    }
    NSString *title = mediaObject.title;
    if (title) {
        self.titleLabel.text = title;
    } else {
        self.titleLabel.text = @"";
    }
    
    self.tallyView.actionsLabel.text = [NSString stringWithFormat:@"%d", [mediaObject.clicks intValue]];
    self.tallyView.viewsLabel.text = [NSString stringWithFormat:@"%d", [mediaObject.views intValue]];
    self.usernameLabel.text = mediaObject.user.username;
    
    [self.profileImageView setImageWithURL:mediaObject.user.thumbnailURL placeholderImage:[UIImage imageNamed:@"user_placeholder.png"]];
    
    self.title = mediaObject.title;
    
    [self refreshTagsForMediaObject:mediaObject];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
