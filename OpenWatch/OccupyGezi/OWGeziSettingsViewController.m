//
//  OWGeziSettingsViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/26/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWGeziSettingsViewController.h"
#import "OWShareController.h"
#import "OWStrings.h"

@interface OWGeziSettingsViewController ()

@end

@implementation OWGeziSettingsViewController

- (void) shareButtonPressed:(id)sender {
    [OWShareController shareURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/occupy-gezi-occupygezi/id667034002?ls=1&mt=8"] title:TWEET_OPENWATCH_STRING fromViewController:self];
}

@end
