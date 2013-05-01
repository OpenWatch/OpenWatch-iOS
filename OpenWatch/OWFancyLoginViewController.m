//
//  OWFancyLoginViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 4/4/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWFancyLoginViewController.h"
#import "OWUtilities.h"

@interface OWFancyLoginViewController ()

@end

@implementation OWFancyLoginViewController
@synthesize backgroundImageView, logoView, blurbLabel, emailField, startButton;


- (id)init
{
    self = [super init];
    if (self) {
        self.emailField = [[UITextField alloc] init];
        self.blurbLabel = [[UILabel alloc] init];
        self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openwatch-light.png"]];
        self.startButton = [OWUtilities bigGreenButton];
    }
    return self;
}

- (void) loadView {
    [super loadView];
    self.backgroundImageView = [[OWKenBurnsView alloc] initWithFrame:self.view.frame];
    self.blurbLabel.text = @"Welcome to OpenWatch! A social muckraking platform. Enter your email address to get started.";
    self.blurbLabel.backgroundColor = [UIColor clearColor];
    self.blurbLabel.textColor = [UIColor whiteColor];
    self.blurbLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    self.blurbLabel.shadowColor = [UIColor blackColor];
    self.blurbLabel.shadowOffset = CGSizeMake(0, -1);
    self.blurbLabel.numberOfLines = 0;
    self.emailField.placeholder = @"Email address";
    self.emailField.borderStyle = UITextBorderStyleRoundedRect;
    [self.startButton setTitle:@"Get Started →" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];

    [self.view addSubview:backgroundImageView];
    [self.view addSubview:logoView];
    [self.view addSubview:blurbLabel];
    [self.view addSubview:emailField];
    [self.view addSubview:startButton];
    self.logoView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.view addSubview:self.scrollView];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    CGFloat xPadding = 20.0f;
    CGFloat yPadding = 20.0f;
    CGFloat logoWidth = self.view.frame.size.width - xPadding * 2;
    self.logoView.frame = CGRectMake(xPadding, yPadding, logoWidth, 100.0f);
    self.blurbLabel.frame = CGRectMake(xPadding, [OWUtilities bottomOfView:logoView] + 20, logoWidth, 100);
    self.emailField.frame = CGRectMake(xPadding, [OWUtilities bottomOfView:blurbLabel] + 20, logoWidth, 30);
    self.startButton.frame = CGRectMake(xPadding, [OWUtilities bottomOfView:emailField] + 20, logoWidth, 50);
    
    self.backgroundImageView.frame = self.view.bounds;
    [backgroundImageView zoomImageView:backgroundImageView.currentImageView];
    [backgroundImageView startTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
