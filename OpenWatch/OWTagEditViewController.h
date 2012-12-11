//
//  OWTagEditViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/10/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWAutocompletionView.h"

@interface OWTagEditViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, OWAutocompletionViewDelegate>

@property (nonatomic, strong) NSManagedObjectID *recordingObjectID;

@end
