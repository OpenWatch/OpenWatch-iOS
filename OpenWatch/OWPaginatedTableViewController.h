//
//  OWPaginatedTableViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/22/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface OWPaginatedTableViewController : UITableViewController  <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic) BOOL isReloading;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
