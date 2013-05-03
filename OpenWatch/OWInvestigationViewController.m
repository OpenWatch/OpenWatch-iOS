//
//  OWInvestigationViewController.m
//  OpenWatch
//
//  Created by David Brodsky on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWInvestigationViewController.h"
#import "OWInvestigation.h"
#import "MBProgressHUD.h"
#import "OWAccountAPIClient.h"

@interface OWInvestigationViewController ()

@end

@implementation OWInvestigationViewController
@synthesize bodyWebView;

- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    [super setMediaObjectID:newMediaObjectID];
    [self refreshFields];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWInvestigation *investigation = (OWInvestigation*)[context existingObjectWithID:self.mediaObjectID error:nil];
    if(!investigation.html){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [[OWAccountAPIClient sharedClient] getInvestigationWithObjectID:self.mediaObjectID success:^(NSManagedObjectID *investigationObjectID) {
        [self refreshFields];
    } failure:^(NSString *reason) {
        
    }];
}

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

- (void)refreshFields
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWInvestigation *investigation = (OWInvestigation*)[context existingObjectWithID:self.mediaObjectID error:nil];
    [self displayHTMLforInvestigation: investigation];
}

- (void)displayHTMLforInvestigation: (OWInvestigation *) inv
{
    [self.bodyWebView loadHTMLString:inv.html baseURL:nil];
}

@end
