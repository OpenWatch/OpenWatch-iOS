//
//  OWLocalMediaEditViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/17/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWPreviewView.h"

@interface OWLocalMediaEditViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) OWPreviewView *previewView;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UILabel *whatHappenedLabel;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UIProgressView *uploadProgressView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSManagedObjectID *objectID;
@property (nonatomic) BOOL showingAfterCapture;

@end
