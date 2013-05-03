//
//  OWInvestigationViewController.h
//  OpenWatch
//
//  Created by David Brodsky on 5/2/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWMediaObjectViewController.h"
#import "OWInvestigation.h"

@interface OWInvestigationViewController : OWMediaObjectViewController <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *bodyWebView;

@end
