//
//  OWProfileViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/30/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWProfileView.h"
#import "OWUser.h"

@interface OWProfileViewController : UIViewController

@property (nonatomic, strong) OWProfileView *profileView;
@property (nonatomic, strong) OWUser *user;

@end
