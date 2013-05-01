//
//  OWFancyLoginViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 4/4/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWKenBurnsView.h"

@interface OWFancyLoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UILabel *blurbLabel;
@property (nonatomic, strong) UIButton *startButton;

@property (nonatomic, strong) OWKenBurnsView *backgroundImageView;
@property (nonatomic, strong) UIImageView *logoView;

@end
