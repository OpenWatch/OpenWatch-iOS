//
//  OWRegistrationViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWRegistrationViewController.h"
#import "Strings.h"

@interface OWRegistrationViewController ()

@end

@implementation OWRegistrationViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = REGISTER_STRING;
    }
    return self;
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
