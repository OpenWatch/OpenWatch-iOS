//
//  OWRecordingInfoViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/26/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWRecording.h"
#import "OWGroupedTableViewController.h"

@interface OWRecordingInfoViewController : OWGroupedTableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UITextField *descriptionTextField;

@property (nonatomic, strong) OWRecording *recording;

- (id) initWithRecording:(OWRecording*)newRecording;

@end
