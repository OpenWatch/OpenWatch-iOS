//
//  OWRootViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/21/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWMissionBadgeView.h"

@interface OWRootViewController : UIViewController

@property (nonatomic, strong) OWMissionBadgeView *badgeView;

- (UIImage*) logoImage;
- (void) setupNavBar;

@end
