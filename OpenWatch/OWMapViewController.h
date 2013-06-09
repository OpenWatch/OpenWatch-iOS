//
//  OWMapViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/9/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OWMapAnnotation.h"

@interface OWMapViewController : UIViewController

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) OWMapAnnotation *annotation;

@end
