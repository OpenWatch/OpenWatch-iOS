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
        self.dashboardTableView.scrollEnabled = NO;
        [self addSubview:dashboardTableView];
        [dashboardTableView registerClass:[OWDashboardTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    }
    return self;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
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
    return ((NSArray*)[dashboardItems objectAtIndex:section]).count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return dashboardItems.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OWDashboardTableViewCell *dashboardCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    dashboardCell.dashboardItem = [[dashboardItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return dashboardCell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OWDashboardItem *dashboardItem = [[dashboardItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (dashboardItem.target && [dashboardItem.target respondsToSelector:dashboardItem.selector]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[dashboardItem.target class] instanceMethodSignatureForSelector:dashboardItem.selector]];
        invocation.target = dashboardItem.target;
        invocation.selector = dashboardItem.selector;
        [invocation setArgument:&dashboardItem atIndex:2];
        [invocation invoke];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dashboardView:didSelectRowAtIndexPath:)]) {
        [self.delegate dashboardView:self didSelectRowAtIndexPath:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
