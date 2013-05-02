//
//  OWInvestigationViewController.m
//  OpenWatch
//
//  Created by David Brodsky on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWInvestigationViewController.h"
#import "OWInvestigation.h"

@interface OWInvestigationViewController ()

@end

@implementation OWInvestigationViewController
@synthesize bodyWebView;

- (void) dealloc {
    if ([bodyWebView isLoading]) {
        [bodyWebView stopLoading];
    }
    self.bodyWebView.delegate = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
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

- (void)setupWebView
{
    self.bodyWebView = [[UIWebView alloc] init];
    self.bodyWebView.scrollView.scrollEnabled = YES;
    self.bodyWebView.delegate = self;
    self.bodyWebView.backgroundColor = [UIColor clearColor];
    self.bodyWebView.opaque = NO;
    
}

- (void)displayHTMLString: (NSString *) htmlString
{
    [self.bodyWebView loadHTMLString:htmlString baseURL:nil];
}

@end
