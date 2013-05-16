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
#import "OWTallyView.h"
#import "OWMediaObjectViewController.h"
#import "DWTagList.h"
#import "OWPreviewView.h"

@interface OWRecordingInfoViewController : OWMediaObjectViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UIScrollViewDelegate, DWTagListDelegate>

@property (nonatomic) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) OWPreviewView *previewView;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) DWTagList *tagList;

// Info view
@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) OWTallyView *tallyView;

@property (nonatomic, strong) UIScrollView *scrollView;

@end
