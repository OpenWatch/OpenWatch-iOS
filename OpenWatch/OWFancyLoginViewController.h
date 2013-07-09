//
//  OWFancyLoginViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 4/4/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWKenBurnsView.h"
#import "BSKeyboardControls.h"
#import "SLGlowingTextField.h"

@interface OWFancyLoginViewController : UIViewController <UITextFieldDelegate, BSKeyboardControlsDelegate>

@property (nonatomic) BOOL processingLogin;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) SLGlowingTextField *emailField;
@property (nonatomic, strong) SLGlowingTextField *passwordField;
@property (nonatomic, strong) UILabel *blurbLabel;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *forgotPasswordButton;

@property (nonatomic, strong) OWKenBurnsView *backgroundImageView;
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;


@end
