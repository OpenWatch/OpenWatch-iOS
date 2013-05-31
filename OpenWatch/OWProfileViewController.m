//
//  OWProfileViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/30/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWProfileViewController.h"

@interface OWProfileViewController ()

@end

@implementation OWProfileViewController
@synthesize profileView, user;

- (id)init
{
    self = [super init];
    if (self) {
        self.profileView = [[OWProfileView alloc] initWithFrame:CGRectZero];
        
        [self.view addSubview:profileView];
    }
    return self;
}

- (void) setUser:(OWUser *)newUser {
    user = newUser;
    self.profileView.user = user;
    self.title = user.username;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat padding = 10.0f;
    CGFloat paddedWidth = self.view.frame.size.width - padding*2;
    self.profileView.frame = CGRectMake(padding, padding, paddedWidth, self.view.frame.size.height - padding);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
