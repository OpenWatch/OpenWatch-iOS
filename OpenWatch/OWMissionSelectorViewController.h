//
//  OWMissionSelectorViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 8/8/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OWMissionSelectorViewController, OWMission;

typedef void(^OWMissionSelectionCallback)(OWMission *selectedMission, NSError *error);

@interface OWMissionSelectorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UITableView *missionsTableView;
@property (nonatomic, strong) NSFetchedResultsController *missionsFRC;
@property (nonatomic, copy) OWMissionSelectionCallback callbackBlock;
@property (nonatomic, strong) OWMission *selectedMission;

- (id) initWithCallbackBlock:(OWMissionSelectionCallback)callbackBlock;


@end
