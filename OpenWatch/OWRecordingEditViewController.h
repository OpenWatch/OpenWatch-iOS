//
//  OWRecordingEditViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/17/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWGroupedTableViewController.h"
#import "DWTagList.h"
#import "OWTagCreationView.h"

@interface OWRecordingEditViewController : UIViewController <DWTagListDelegate, UITextFieldDelegate, OWTagCreationViewDelegate>

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UITextField *descriptionTextField;
@property (nonatomic, strong) UILabel *whatHappenedLabel;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UIProgressView *uploadProgressView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) DWTagList *tagList;
@property (nonatomic, strong) OWTagCreationView *tagCreationView;

@property (nonatomic, strong) NSManagedObjectID *recordingID;

@end
