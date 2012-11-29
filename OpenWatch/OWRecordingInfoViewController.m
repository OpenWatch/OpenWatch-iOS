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
#import "OWMapAnnotation.h"

@interface OWRecordingInfoViewController ()
@property (nonatomic) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UITextField *descriptionTextField;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UIProgressView *uploadProgressView;
@end

@implementation OWRecordingInfoViewController
@synthesize recording, titleTextField, descriptionTextField, mapView, moviePlayer, centerCoordinate, uploadProgressView;

- (id) init {
    if (self = [super init]) {
        [self setupMapView];
        self.moviePlayer = [[MPMoviePlayerController alloc] init];
        self.title = INFO_STRING;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:SAVE_STRING style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
        [self setupFields];
        [self setupProgressView];
    }
    return self;
}

- (void) setupMapView {
    self.mapView = [[MKMapView alloc] init];
    mapView.scrollEnabled = NO;
    mapView.zoomEnabled = NO;
    mapView.delegate = self;
    [self.scrollView addSubview:mapView];
}

- (void) setupProgressView {
    self.uploadProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self addCellInfoWithSection:0 row:2 labelText:PROGRESS_STRING cellType:kCellTypeProgress userInputView:self.uploadProgressView];
}

- (void) refreshProgressView {
    if (recording) {
        float progress = ((float)[recording completedFileCount]) / [recording totalFileCount];
        [self.uploadProgressView setProgress:progress animated:YES];
    }
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
    if (!CLLocationCoordinate2DIsValid(centerCoordinate)) {
        mapViewHeight = 0.0f;
    }
    self.mapView.frame = CGRectMake(0, 0, self.view.frame.size.width, mapViewHeight);
    contentHeight += mapViewHeight;
    CGFloat groupedTableHeight = 150.0f;
    CGFloat groupedTableViewYOrigin = self.mapView.frame.origin.y + self.mapView.frame.size.height + padding;
    self.groupedTableView.frame = CGRectMake(0, groupedTableViewYOrigin, self.view.frame.size.width, groupedTableHeight);
    contentHeight += groupedTableHeight + padding;
    CGFloat moviePlayerYOrigin = self.groupedTableView.frame.origin.y + self.groupedTableView.frame.size.height + padding;
    CGFloat moviePlayerHeight = 250.0f;
    moviePlayer.view.frame = CGRectMake(0, moviePlayerYOrigin, self.view.frame.size.width, moviePlayerHeight);
    contentHeight += moviePlayerHeight + padding;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentHeight);
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshFrames];
    [self registerForUploadProgressNotifications];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) registerForUploadProgressNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (recording) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUploadProgressNotification:) name:kOWCaptureAPIClientBandwidthNotification object:recording];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (CLLocationCoordinate2DIsValid(centerCoordinate)) {
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(centerCoordinate, 1000, 1000) animated:YES];
    }
    [moviePlayer play];
}

- (void) setRecording:(OWRecording *)newRecording {
    recording = newRecording;
    self.moviePlayer.contentURL = [recording highQualityURL];
    [moviePlayer prepareToPlay];
    [self refreshMapParameters];
    [self refreshFields];
    [self refreshFrames];
    [self refreshProgressView];
    [self registerForUploadProgressNotifications];
}

- (void) receivedUploadProgressNotification:(NSNotification*)notification {
    [self refreshProgressView];
}

- (void) refreshMapParameters {
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
    NSString *title = recording.title;
    if (title) {
        self.titleTextField.text = title;
    } else {
        self.titleTextField.text = @"";
    }
    NSString *description = recording.recordingDescription;
    if (description) {
        self.descriptionTextField.text = description;
    } else {
        self.descriptionTextField.text = @"";
    }
}

-(void)setupFields {
    self.titleTextField = [self textFieldWithDefaults];
    self.titleTextField.placeholder = REQUIRED_STRING;

    [self addCellInfoWithSection:0 row:0 labelText:TITLE_STRING cellType:kCellTypeTextField userInputView:self.titleTextField];
    
    self.descriptionTextField = [self textFieldWithDefaults];

    [self addCellInfoWithSection:0 row:1 labelText:DESCRIPTION_STRING cellType:kCellTypeTextField userInputView:self.descriptionTextField];
}

- (UITextField*)textFieldWithDefaults {
    UITextField *textField = [[UITextField alloc] init];
    textField.delegate = self;
    textField.autocorrectionType = UITextAutocorrectionTypeDefault;
    textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textColor = self.textFieldTextColor;
    return textField;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) saveButtonPressed:(id)sender {
    self.recording.title = self.titleTextField.text;
    self.recording.recordingDescription = self.descriptionTextField.text;
    [self.recording saveMetadata];
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
