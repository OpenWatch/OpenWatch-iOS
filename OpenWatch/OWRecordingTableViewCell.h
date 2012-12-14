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

@property (nonatomic, strong) NSManagedObjectID *recordingObjectID;
@property (nonatomic, strong) UILabel *actionsLabel;
@property (nonatomic, strong) UILabel *viewsLabel;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UIImageView *eyeImageView;
@property (nonatomic, strong) UIImageView *actionImageView;
@property (nonatomic, strong) UIView *tallyView;
@property (nonatomic, strong) UILabel *dateModifiedLabel;
@property (nonatomic) BOOL isLocalRecording;

@end
