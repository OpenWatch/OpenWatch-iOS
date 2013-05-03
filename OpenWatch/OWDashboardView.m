//
//  OWDashboardView.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/3/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWDashboardView.h"
#import "OWDashboardItem.h"
#import "OWDashboardTableViewCell.h"

static NSString *cellIdentifier = @"cellIdentifier";

@implementation OWDashboardView
@synthesize dashboardItems, dashboardTableView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dashboardItems = [NSArray array];
        self.dashboardTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        self.dashboardTableView.delegate = self;
        self.dashboardTableView.dataSource = self;
        self.dashboardTableView.backgroundColor = [UIColor clearColor];
        self.dashboardTableView.backgroundView = nil;
        [self addSubview:dashboardTableView];
        [dashboardTableView registerClass:[OWDashboardTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.dashboardTableView.frame = frame;
}

- (void) setDashboardItems:(NSArray *)newDashboardItems {
    dashboardItems = newDashboardItems;
    [self.dashboardTableView reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dashboardItems.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OWDashboardTableViewCell *dashboardCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    dashboardCell.dashboardItem = [dashboardItems objectAtIndex:indexPath.row];
    return dashboardCell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dashboardView:didSelectRowAtIndexPath:)]) {
        [self.delegate dashboardView:self didSelectRowAtIndexPath:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
