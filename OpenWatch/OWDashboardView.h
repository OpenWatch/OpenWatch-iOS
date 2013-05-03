//
//  OWDashboardView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/3/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OWDashboardView;

@protocol OWDashboardViewDelegate <NSObject>
@optional
- (void) dashboardView:(OWDashboardView*)dashboardView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface OWDashboardView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *dashboardTableView;
@property (nonatomic, strong) NSArray *dashboardItems;
@property (nonatomic, weak) id<OWDashboardViewDelegate> delegate;

@end
