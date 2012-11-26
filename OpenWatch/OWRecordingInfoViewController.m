//
//  OWRecordingInfoViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/26/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWRecordingInfoViewController.h"
#import "OWStrings.h"
#import "OWMapAnnotation.h"

@interface OWRecordingInfoViewController ()

@end

@implementation OWRecordingInfoViewController
@synthesize recording, titleTextField, descriptionTextField, mapView, moviePlayer;

- (id) initWithRecording:(OWRecording *)newRecording {
    if (self = [super init]) {
        self.recording = newRecording;


    }
    return self;
}

- (void) setupMapView {
    self.mapView = [[MKMapView alloc] init];
    CLLocation *loc = recording.startLocation;
    if (!loc) {
        loc = recording.endLocation;
    }
    [self.mapView setCenterCoordinate:loc.coordinate];
    mapView.scrollEnabled = NO;
    mapView.zoomEnabled = NO;
    [self.scrollView addSubview:mapView];
    
    if (recording.startLocation) {
        OWMapAnnotation *startAnnotation = [[OWMapAnnotation alloc] initWithCoordinate:recording.startLocation.coordinate title:START_STRING subtitle:nil];
        [mapView addAnnotation:startAnnotation];
    }
    if (recording.endLocation) {
        OWMapAnnotation *endAnnotation = [[OWMapAnnotation alloc] initWithCoordinate:recording.endLocation.coordinate title:END_STRING subtitle:nil];
        [mapView addAnnotation:endAnnotation];
    }

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (recording.startLocation || recording.endLocation) {
        [self setupMapView];
    }
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[recording highQualityURL]];
    [moviePlayer prepareToPlay];
    [self refreshFrames];
}

- (void) refreshFrames {
    CGFloat padding = 10.0f;
    [UIView animateWithDuration:0.2 animations:^{
        self.mapView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100.0f);
        self.groupedTableView.frame = CGRectMake(0, self.mapView.frame.origin.y + self.mapView.frame.size.height + padding, self.view.frame.size.width, 200.0f);
    } completion:^(BOOL finished) {
        [mapView setRegion:MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, 500, 500) animated:YES];
    }];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupFields];
}

-(void)setupFields {
    self.titleTextField = [self textFieldWithDefaults];
    self.titleTextField.placeholder = REQUIRED_STRING;
    NSString *title = recording.title;
    if (title) {
        self.titleTextField.text = title;
    }
    [self addCellInfoWithSection:0 row:0 labelText:TITLE_STRING cellType:kCellTypeTextField userInputView:self.titleTextField];
    
    self.descriptionTextField = [self textFieldWithDefaults];
    NSString *description = recording.recordingDescription;
    if (description) {
        self.descriptionTextField.text = description;
    }
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

@end
