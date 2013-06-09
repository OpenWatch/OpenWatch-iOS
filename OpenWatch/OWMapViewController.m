//
//  OWMapViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/9/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWMapViewController.h"
#import "OWStrings.h"

@interface OWMapViewController ()

@end

@implementation OWMapViewController
@synthesize mapView, annotation;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = VIEW_ON_MAP_STRING;
        self.mapView = [[MKMapView alloc] init];
        [self.view addSubview:mapView];
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [mapView removeAnnotations:mapView.annotations];
    
    [self.mapView addAnnotation:annotation];
    
    self.mapView.frame = self.view.bounds;
}

- (void) viewDidAppear:(BOOL)animated {
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000) animated:YES];
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

@end
