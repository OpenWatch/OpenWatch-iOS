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
#import "OWTagEditViewController.h"
#import "OWUtilities.h"


@interface OWRecordingInfoViewController ()
@end

@implementation OWRecordingInfoViewController
@synthesize recordingID, mapView, moviePlayer, centerCoordinate, scrollView;
@synthesize titleLabel, descriptionLabel;

- (id) init {
    if (self = [super init]) {
        [self setupMapView];
        self.moviePlayer = [[MPMoviePlayerController alloc] init];
        self.title = INFO_STRING;
    }
    return self;
}

- (void) setupMapView {
    if (mapView) {
        [mapView removeFromSuperview];
    }
    self.mapView = [[MKMapView alloc] init];
    mapView.scrollEnabled = NO;
    mapView.zoomEnabled = NO;
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
    CGFloat padding = 10.0f;
    CGFloat contentHeight = 0.0f;
    CGFloat mapViewHeight = 100.0f;
    CGFloat mapViewWidth = self.view.frame.size.width;
    if (!CLLocationCoordinate2DIsValid(centerCoordinate)) {
        mapViewHeight = 0.0f;
        mapViewWidth = 0.0f;
    }
    self.mapView.frame = CGRectMake(0, 0, mapViewWidth, mapViewHeight);
    contentHeight += mapViewHeight;
    
    CGFloat titleYOrigin;
    CGFloat itemHeight = 30.0f;
    CGFloat itemWidth = self.view.frame.size.width - padding*2;

    CGFloat moviePlayerYOrigin = 0;
    CGFloat moviePlayerHeight = 250.0f;
    moviePlayer.view.frame = CGRectMake(0, moviePlayerYOrigin, self.view.frame.size.width, moviePlayerHeight);
    /*
    self.titleTextField.frame = CGRectMake(padding, titleYOrigin, itemWidth, itemHeight);
    CGFloat descriptionYOrigin = [OWUtilities bottomOfView:titleTextField] + padding;
    self.descriptionTextField.frame = CGRectMake(padding, descriptionYOrigin, itemWidth, 100.0f);
    CGFloat tableViewYOrigin = [OWUtilities bottomOfView:descriptionTextField] + padding;
    self.groupedTableView.frame = CGRectMake(0, tableViewYOrigin, self.view.frame.size.width, 70.0f);
    contentHeight = [OWUtilities bottomOfView:self.groupedTableView] + padding*3;
     */

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentHeight);
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshFrames];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self resignFirstResponder];
    [moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (CLLocationCoordinate2DIsValid(centerCoordinate)) {
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(centerCoordinate, 1000, 1000) animated:YES];
    }
    [moviePlayer play];
}

- (void) setRecordingID:(NSManagedObjectID *)newRecordingID {
    recordingID = newRecordingID;
    [self setupFields];
    

    OWManagedRecording *recording = [OWRecordingController recordingForObjectID:recordingID];
    [[OWAccountAPIClient sharedClient] getRecordingWithUUID:recording.uuid success:^(NSManagedObjectID *recordingObjectID) {
        OWManagedRecording *remoteRecording = [OWRecordingController recordingForObjectID:recordingObjectID];
        self.moviePlayer.contentURL = [NSURL URLWithString:[remoteRecording remoteVideoURL]];
        [moviePlayer prepareToPlay];
        [self refreshMapParameters];
        [self refreshFields];
        [self refreshFrames];
    } failure:^(NSString *reason) {
        
    }];
    


}

- (void) setupFields {
    self.descriptionLabel = [[UILabel alloc] init];
    self.titleLabel = [[UILabel alloc] init];
}


- (void) refreshMapParameters {
    OWLocalRecording *recording = [OWRecordingController recordingForObjectID:self.recordingID];
    double lat = 0.0f;
    double lon = 0.0f;
    CLLocation *start = recording.startLocation;
    CLLocation *end = recording.endLocation;
    if (start) {
        lat = start.coordinate.latitude;
        lon = start.coordinate.longitude;
        if (end) {
            lat = (lat + end.coordinate.latitude) / 2;
            lon = (lon + end.coordinate.longitude) / 2;
        }
    } else if (end) {
        lat = end.coordinate.latitude;
        lon = end.coordinate.longitude;
    }

    if (lat != 0.0f && lon != 0.0f) {
        self.centerCoordinate = CLLocationCoordinate2DMake(lat, lon);
    } else {
        self.centerCoordinate = CLLocationCoordinate2DMake(-255, -255);
    }
    
    [mapView removeAnnotations:[mapView annotations]];
    if (recording.startLocation) {
        OWMapAnnotation *startAnnotation = [[OWMapAnnotation alloc] initWithCoordinate:recording.startLocation.coordinate title:START_STRING subtitle:nil];
        startAnnotation.isStartLocation = YES;
        [mapView addAnnotation:startAnnotation];
    }
    if (recording.endLocation) {
        OWMapAnnotation *endAnnotation = [[OWMapAnnotation alloc] initWithCoordinate:recording.endLocation.coordinate title:END_STRING subtitle:nil];
        [mapView addAnnotation:endAnnotation];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:moviePlayer.view];
    self.scrollView.scrollEnabled = YES;
}

- (void) refreshFields {
    OWManagedRecording *recording = [OWRecordingController recordingForObjectID:self.recordingID];
    NSString *title = recording.title;
    if (title) {
        self.titleLabel.text = title;
    } else {
        self.titleLabel.text = @"";
    }
    NSString *description = recording.recordingDescription;
    if (description) {
        self.descriptionLabel.text = description;
    } else {
        self.descriptionLabel.text = @"";
    }
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
