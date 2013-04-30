//
//  OWFancyLoginViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 4/4/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWFancyLoginViewController.h"

@interface OWFancyLoginViewController ()

@end

@implementation OWFancyLoginViewController
@synthesize backgroundImageView, logoView;


- (id)init
{
    self = [super init];
    if (self) {
        //self.logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openwatch-light.png"]];
    }
    return self;
}

- (void) loadView {
    [super loadView];
    self.backgroundImageView = [[OWKenBurnsView alloc] initWithFrame:self.view.frame];

    [self.view addSubview:backgroundImageView];
    //[self.view addSubview:logoView];
    //self.logoView.contentMode = UIViewContentModeScaleAspectFit;
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
