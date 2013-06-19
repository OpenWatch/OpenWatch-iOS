//
//  OWFeedSelectionViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WEPopoverController.h"

typedef enum {
    kOWFeedTypeFeed = 1,
    kOWFeedTypeFrontPage = 2,
    kOWFeedTypeMissions = 3,
    kOWFeedTypeTag
} OWFeedType;

@protocol OWFeedSelectionDelegate <NSObject>
@required
- (void) didSelectFeedWithName:(NSString*)feedName type:(OWFeedType)type;
@property (nonatomic, strong) NSString *selectedFeedString;
@property (nonatomic) OWFeedType feedType;
@end

@interface OWFeedSelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *selectionTableView;
@property (nonatomic, strong) NSArray *feedNames;
@property (nonatomic, strong) NSArray *tagNames;
@property (nonatomic) CGSize popoverSize;
@property (nonatomic, strong) WEPopoverController *popOver;
@property (nonatomic, weak) id<OWFeedSelectionDelegate> delegate;

- (void) presentPopoverFromBarButtonItem:(UIBarButtonItem*)buttonItem;

@end
