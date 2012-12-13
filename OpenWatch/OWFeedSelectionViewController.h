//
//  OWFeedSelectionViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WEPopoverController.h"

@protocol OWFeedSelectionDelegate <NSObject>
- (void) didSelectTagWithName:(NSString*)tagName;
- (void) didSelectFeedWithName:(NSString*)feedName;
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
