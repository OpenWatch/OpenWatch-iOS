//
//  OWWelcomeViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/17/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWWelcomeViewController.h"
#import "OWStrings.h"
#import "OWUtilities.h"

#define PADDING 10.0f

@interface OWWelcomeViewController ()

@end

@implementation OWWelcomeViewController
@synthesize welcomeLabel, welcomeTextView;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = OPENWATCH_STRING;
        self.welcomeLabel = [[UILabel alloc] init];
        self.welcomeTextView = [[UITextView alloc] init];
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:COOL_STRING style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonPressed:)];
        self.navigationItem.rightBarButtonItem.tintColor = [OWUtilities doneButtonColor];
    }
    return self;
}

- (void) rightButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    welcomeLabel.text = WELCOME_STRING;
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    welcomeLabel.shadowColor = [UIColor lightGrayColor];
    welcomeLabel.shadowOffset = CGSizeMake(0, 1);
    welcomeLabel.textColor = [OWUtilities greyTextColor];
    welcomeTextView.text = WELCOME_TEXTVIEW_STRING;
    welcomeTextView.backgroundColor = [UIColor clearColor];
    welcomeTextView.font = [UIFont systemFontOfSize:16.0f];
    welcomeTextView.textColor = [OWUtilities greyTextColor];
    [self.view addSubview:welcomeLabel];
    [self.view addSubview:welcomeTextView];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.welcomeLabel.frame = CGRectMake(PADDING, PADDING, self.view.frame.size.width-PADDING*2, 50.0f);
    CGFloat welcomeTextYOrigin = welcomeLabel.frame.origin.y + welcomeLabel.frame.size.height + PADDING;
    self.welcomeTextView.frame = CGRectMake(PADDING, welcomeTextYOrigin, self.view.frame.size.width-PADDING*2, self.view.frame.size.height - welcomeTextYOrigin - PADDING);
    [TestFlight passCheckpoint:WELCOME_CHECKPOINT];
}


@end
