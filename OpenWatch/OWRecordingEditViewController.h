//
//  OWRecordingEditViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/17/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWTagEditView.h"

@interface OWRecordingEditViewController : UIViewController <UITextFieldDelegate, OWTagEditViewDelegate>

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UITextField *descriptionTextField;
@property (nonatomic, strong) UILabel *whatHappenedLabel;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UIProgressView *uploadProgressView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) OWTagEditView *tagEditView;

@property (nonatomic, strong) NSManagedObjectID *recordingID;
@property (nonatomic) BOOL showingAfterCapture;

@end
