//
//  OWFeedViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/11/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWPaginatedTableViewController.h"
#import "OWLocationController.h"

typedef enum {
    kOWFeedTypeNone = 0,
    kOWFeedTypeFeed = 1,
    kOWFeedTypeFrontPage = 2,
    kOWFeedTypeMissions = 3,
    kOWFeedTypeTag
} OWFeedType;

@interface OWFeedViewController : OWPaginatedTableViewController < OWLocationControllerDelegate>

@property (nonatomic, strong) CLLocation *lastLocation;

- (void) didSelectFeedWithName:(NSString *)feedName displayName:(NSString*)displayName type:(OWFeedType)type;
- (void) didSelectFeedWithName:(NSString *)feedName displayName:(NSString*)displayName type:(OWFeedType)type pageNumber:(NSUInteger)pageNumber;
@property (nonatomic, strong) NSString *selectedFeedString;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic) OWFeedType feedType;

@end
