//
//  OWGeziDashboardViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/26/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWGeziDashboardViewController.h"
#import "OWDashboardItem.h"
#import "OWStrings.h"
#import "OWTagDashboardItem.h"
#import "OWFeedViewController.h"

@interface OWGeziDashboardViewController ()

@end

@implementation OWGeziDashboardViewController

- (void) setupStaticDashboardItems {
    OWDashboardItem *topStories = [[OWDashboardItem alloc] initWithTitle:TOP_STORIES_STRING image:[UIImage imageNamed:@"28-star.png"] target:self selector:@selector(feedButtonPressed:)];
    OWDashboardItem *local = [[OWDashboardItem alloc] initWithTitle:LOCAL_FEED_STRING image:[UIImage imageNamed:@"193-location-arrow.png"] target:self selector:@selector(localFeedButtonPressed:)];
    OWDashboardItem *yourMedia = [[OWDashboardItem alloc] initWithTitle:YOUR_MEDIA_STRING image:[UIImage imageNamed:@"160-voicemail-2.png"] target:self selector:@selector(yourMediaPressed:)];
    
    OWDashboardItem *feedback = [[OWDashboardItem alloc] initWithTitle:SEND_FEEDBACK_STRING image:[UIImage imageNamed:@"29-heart.png"] target:self selector:@selector(feedbackButtonPressed:)];
    OWDashboardItem *settings = [[OWDashboardItem alloc] initWithTitle:SETTINGS_STRING image:[UIImage imageNamed:@"19-gear.png"] target:self selector:@selector(settingsButtonPressed:)];
    
    NSArray *middleItems = @[topStories, local, yourMedia];
    NSArray *bottonItems = @[feedback, settings];
    NSArray *dashboardItems = @[middleItems, bottonItems];
    self.staticDashboardItems = dashboardItems;
    self.dashboardView.dashboardItems = dashboardItems;
}

- (void) feedButtonPressed:(id)sender {
    [self selectFeed:@"occupygezi" type:kOWFeedTypeTag];
}

- (void) refreshTagList {
    OWTag *tag = [OWTag tagWithName:@"occupygezi"];
    NSString *displayName = [NSString stringWithFormat:@"#%@", tag.name];
    OWTagDashboardItem *dashboardItem = [[OWTagDashboardItem alloc] initWithTitle:displayName image:nil target:self selector:@selector(didSelectTagWithName:)];
    dashboardItem.tag = tag;
    NSArray *newDashboardItems = @[dashboardItem];
    NSMutableArray *newDashboard = [NSMutableArray arrayWithArray:self.staticDashboardItems];
    [newDashboard addObject:newDashboardItems];
    self.dashboardView.dashboardItems = newDashboard;
}

@end
