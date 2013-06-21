//
//  OWRootViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/21/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWRootViewController.h"
#import "OWUtilities.h"
#import "OWStrings.h"
#import "PKRevealController.h"
#import "OWAppDelegate.h"

@interface OWRootViewController ()

@end

@implementation OWRootViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [OWUtilities stoneBackgroundPattern];
        [self setupNavBar];
    }
    return self;
}

- (void) setupNavBar {
    self.title = WATCH_STRING;
    UIImage *revealImagePortrait = [UIImage imageNamed:@"reveal_menu_icon_portrait"];
    
    self.navigationItem.leftBarButtonItem =
    [OWUtilities barItemWithImage:revealImagePortrait target:self action:@selector(showLeftView:)];
    self.navigationItem.rightBarButtonItem = [OWUtilities barItemWithImage:[UIImage imageNamed:@"285-facetime.png"] target:self action:@selector(startRecording:)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openwatch.png"]];
    imageView.frame = CGRectMake(0, 0, 140, 25);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
}


- (void) showLeftView:(id)sender {
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController) {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    } else {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}



- (void) startRecording:(id)sender {
    OW_APP_DELEGATE.creationController.primaryTag = nil;
    [OW_APP_DELEGATE.creationController recordVideoFromViewController:self];
}


@end
