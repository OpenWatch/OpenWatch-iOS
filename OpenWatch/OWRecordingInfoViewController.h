//
//  OWRecordingInfoViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/26/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWLocalRecording.h"
#import "OWGroupedTableViewController.h"
#import <MapKit/MapKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface OWRecordingInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (nonatomic) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *infoView;

@property (nonatomic, strong) NSManagedObjectID *recordingID;
@property (nonatomic, strong) UIScrollView *scrollView;

@end
