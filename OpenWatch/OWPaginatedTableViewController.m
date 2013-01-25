//
//  OWPaginatedTableViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/22/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWPaginatedTableViewController.h"
#import "OWMediaObjectTableViewCell.h"
#import "OWUtilities.h"

#define kLoadingCellTag 31415

@interface OWPaginatedTableViewController ()

@end

@implementation OWPaginatedTableViewController
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize isReloading;
@synthesize currentPage;
@synthesize totalPages;
@synthesize objectIDs;

- (id)init
{
    self = [super init];
    if (self) {
        self.tableView.backgroundColor = [OWUtilities fabricBackgroundPattern];
        currentPage = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
        view.backgroundColor = [UIColor clearColor];
		[self.tableView addSubview:view];
		_refreshHeaderView = view;		
	}
	[_refreshHeaderView refreshLastUpdatedDate];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource {
	isReloading = YES;
}

- (void)doneLoadingTableViewData {
    isReloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return isReloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (currentPage == 0) {
        return 0;
    }
    
    if (currentPage == totalPages) {
        return self.objectIDs.count;
    }
    return self.objectIDs.count + 1;
}

- (UITableViewCell *)mediaObjectCellForIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MediaObjectCellIdentifier";
    OWMediaObjectTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[OWMediaObjectTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSManagedObjectID *recordingObjectID = [self.objectIDs objectAtIndex:indexPath.row];
    cell.mediaObjectID = recordingObjectID;
    return cell;
    
    return cell;
}

- (UITableViewCell *)loadingCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:nil];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = cell.center;
    [cell addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
    
    cell.tag = kLoadingCellTag;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.objectIDs.count) {
        return 45.0f;
    }
    return 147.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objectIDs.count) {
        return [self mediaObjectCellForIndexPath:indexPath];
    } else {
        return [self loadingCell];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kLoadingCellTag && currentPage <= totalPages) {
        currentPage++;
        [self fetchObjectsForPageNumber:currentPage];
    }
}

- (void) reloadFeed:(NSArray*)recordings replaceObjects:(BOOL)replaceObjects {
    if (replaceObjects) {
        self.objectIDs = [NSMutableArray arrayWithArray:recordings];
    } else {
        [self.objectIDs addObjectsFromArray:recordings];
    }
    [self.tableView reloadData];
    
	[self doneLoadingTableViewData];
}

- (void) failedToLoadFeed:(NSString*)reason {
    [self doneLoadingTableViewData];
}

- (void) fetchObjectsForPageNumber:(NSUInteger)pageNumber {}


@end
