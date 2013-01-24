//
//  OWPaginatedTableViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/22/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

#define kFirstPage 1

@interface OWPaginatedTableViewController : UIViewController  <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) NSUInteger totalPages;
@property (nonatomic) BOOL isReloading;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, strong) NSMutableArray *objectIDs;

- (void) reloadTableViewDataSource;
- (void) doneLoadingTableViewData;
- (void) fetchObjectsForPageNumber:(NSUInteger)pageNumber; // stub method, implement in subclass
- (void) reloadFeed:(NSArray*)recordings replaceObjects:(BOOL)replaceObjects;
- (void) failedToLoadFeed:(NSString*)reason;

@end
