//
//  OWTagEditViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/10/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWAutocompletionViewController.h"

@interface OWTagEditViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, OWAutocompletionDelegate>

@property (nonatomic, strong) NSManagedObjectID *recordingObjectID;
@property (nonatomic) BOOL isLocalRecording;
@property (nonatomic, strong) OWAutocompletionViewController *autocompletionView;

@end
