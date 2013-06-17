//
//  OWShareViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/14/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWShareViewController.h"
#import "OWShareController.h"
#import "OWUtilities.h"
#import "OWAccountAPIClient.h"
#import "OWLocalMediaController.h"
#import "MBProgressHUD.h"
#import "OWStrings.h"

@interface OWShareViewController ()

@end

@implementation OWShareViewController
@synthesize titleLabel, urlLabel, previewView, mediaObject, shareButton, skipButton, descriptionLabel;

- (id)init
{
    self = [super init];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = ITS_ONLINE_STRING;
        self.urlLabel = [[UILabel alloc] init];
        self.urlLabel.text = GENERATING_URL_STRING;
        
        self.descriptionLabel = [[UILabel alloc] init];
        self.descriptionLabel.text = CALL_TO_ACTION_SHARE_STRING;
        self.descriptionLabel.numberOfLines = 0;
        self.previewView = [[OWPreviewView alloc] initWithFrame:CGRectZero];
        
        [OWUtilities styleLabel:titleLabel];
        [OWUtilities styleLabel:urlLabel];
        [OWUtilities styleLabel:descriptionLabel];
        
        self.titleLabel.font = [UIFont boldSystemFontOfSize:21.0f];
        self.urlLabel.font = [UIFont systemFontOfSize:16.0f];
        self.descriptionLabel.font = [UIFont systemFontOfSize:13.0f];
        self.urlLabel.adjustsFontSizeToFitWidth = YES;
        
        self.shareButton = [[BButton alloc] initWithFrame:CGRectZero type:BButtonTypeSuccess icon:nil fontSize:22.0f];
        [self.shareButton setTitle:SHARE_STRING forState:UIControlStateNormal];
        [self.shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.shareButton addAwesomeIcon:FAIconShare beforeTitle:YES];
        self.title = SHARE_STRING;
        self.shareButton.enabled = NO;
        
        [self.navigationItem setHidesBackButton:YES animated:NO];
        
        self.skipButton = [[UIBarButtonItem alloc] initWithTitle:FINISH_STRING style:UIBarButtonItemStyleBordered target:self action:@selector(skipButtonPressed:)];
        self.navigationItem.rightBarButtonItem = skipButton;
        
        [self.view addSubview:shareButton];
        [self.view addSubview:descriptionLabel];
        [self.view addSubview:urlLabel];
        [self.view addSubview:titleLabel];
        [self.view addSubview:previewView];
    }
    return self;
}

- (void) shareButtonPressed:(id)sender {
    [OWShareController shareMediaObject:self.mediaObject fromViewController:self];
}

- (void) skipButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) setMediaObject:(OWLocalMediaObject *)newMediaObject {
    mediaObject = newMediaObject;
    
    if (mediaObject.shareURL) {
        self.shareButton.enabled = YES;
        self.urlLabel.text = mediaObject.shareURL.absoluteString;
    } else {
        self.shareButton.enabled = NO;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[OWAccountAPIClient sharedClient] getObjectWithUUID:mediaObject.uuid objectClass:[mediaObject class] success:^(NSManagedObjectID *objectID) {
            OWLocalMediaObject *newObject = [OWLocalMediaController localMediaObjectForObjectID:objectID];
            self.urlLabel.text = newObject.shareURL.absoluteString;
            self.shareButton.enabled = YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } failure:^(NSString *reason) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } retryCount:kOWAccountAPIClientDefaultRetryCount];
    }
    
    self.previewView.objectID = mediaObject.objectID;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGFloat padding = 10.0f;
    CGFloat buttonHeight = 50.0f;

    CGFloat itemWidth = self.view.frame.size.width - padding * 2;
    CGFloat previewHeight = [OWPreviewView heightForWidth:itemWidth];

    self.titleLabel.frame = CGRectMake(padding, padding, itemWidth, 21);
    
    self.previewView.frame = CGRectMake(padding, [OWUtilities bottomOfView:titleLabel] + padding, itemWidth, previewHeight);
    self.urlLabel.frame = CGRectMake(padding, [OWUtilities bottomOfView:previewView] + padding, itemWidth, 20);
    self.shareButton.frame = CGRectMake(padding, [OWUtilities bottomOfView:urlLabel] + padding, itemWidth, buttonHeight);

    self.descriptionLabel.frame = CGRectMake(padding, [OWUtilities bottomOfView:shareButton] + padding, itemWidth, 40);
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
