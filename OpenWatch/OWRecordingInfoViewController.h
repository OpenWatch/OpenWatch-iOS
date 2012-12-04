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

@interface OWRecordingInfoViewController : OWGroupedTableViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (nonatomic, strong) OWLocalRecording *recording;

@end
