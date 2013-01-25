//
//  OWHomeScreenViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/29/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWLabeledButtonView.h"

@interface OWHomeScreenViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) UIView *gridView;

@property (nonatomic, strong) OWLabeledButtonView *recordButtonView;
@property (nonatomic, strong) OWLabeledButtonView *watchButtonView;
@property (nonatomic, strong) OWLabeledButtonView *localButtonView;
@property (nonatomic, strong) OWLabeledButtonView *savedButtonView;
@property (nonatomic, strong) OWLabeledButtonView *settingsButtonView;

@end
