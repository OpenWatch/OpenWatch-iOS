//
//  OWMediaObjectViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/14/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWMediaObjectViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectID *mediaObjectID;
@property (nonatomic, strong) UIBarButtonItem *shareButton;
@property (nonatomic, strong) UIBarButtonItem *recordButton;

@end
