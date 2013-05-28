//
//  OWLoginViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWAccount.h"
#import "OWGroupedTableViewController.h"

@interface OWLoginViewController : OWGroupedTableViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL showCancelButton;
@property (nonatomic, strong) UIButton *forgotPasswordButton;

@property (nonatomic, strong) OWAccount *account;

@property (nonatomic, strong) UIImageView *headerImageView;

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *passwordTextField;

@property (nonatomic, strong) UIBarButtonItem *loginButton;
@property (nonatomic, strong) UIBarButtonItem *logoutButton;

@property (nonatomic, strong) UILabel *helpLabel;

@property (nonatomic, strong) UISegmentedControl *loginOrSignupSegmentedControl;

@end
