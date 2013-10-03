//
//  OWAvamMissionListViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 10/2/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWAvamMissionListViewController.h"
#import "OWAccountAPIClient.h"
#import "OWAvamOnboardingView.h"

@implementation OWAvamMissionListViewController

- (void) didSelectFeedWithPageNumber:(NSUInteger)pageNumber {
    if (pageNumber <= kFirstPage) {
        self.currentPage = kFirstPage;
    }
    NSDictionary *additionalParameters = @{@"avam": @YES};
    
    [[OWAccountAPIClient sharedClient] fetchMediaObjectsForFeedType:kOWFeedTypeMissions feedName:nil page:pageNumber additionalParameters:additionalParameters success:^(NSArray *mediaObjectIDs, NSUInteger totalPages) {
        self.totalPages = totalPages;
        BOOL shouldReplaceObjects = NO;
        if (self.currentPage == kFirstPage) {
            shouldReplaceObjects = YES;
        }
        [self reloadFeed:mediaObjectIDs replaceObjects:shouldReplaceObjects];
        [self doneLoadingTableViewData];
    } failure:^(NSString *reason) {
        [self doneLoadingTableViewData];
    }];
}

- (Class) onboardingViewClass {
    return [OWAvamOnboardingView class];
}

@end
