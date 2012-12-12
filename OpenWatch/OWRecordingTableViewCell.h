//
//  OWRecordingTableViewCell.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWManagedRecording.h"

@interface OWRecordingTableViewCell : UITableViewCell

@property (nonatomic, strong) OWManagedRecording *recording;
@property (nonatomic, strong) UILabel *upvotesLabel;
@property (nonatomic, strong) UILabel *viewsLabel;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@end
