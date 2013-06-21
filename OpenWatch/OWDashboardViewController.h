//
//  OWDashboardViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWPaginatedTableViewController.h"
#import "OWDashboardView.h"
#import "OWAudioRecordingViewController.h"
#import "OWCaptureViewController.h"
#import "OWLocationController.h"
#import "OWMediaCreationController.h"

@interface OWDashboardViewController : UIViewController < OWDashboardViewDelegate, OWLocationControllerDelegate>

@property (nonatomic, strong) OWDashboardView *dashboardView;

@property (nonatomic, strong) NSArray *staticDashboardItems;

- (void) refreshTagList;

@end
