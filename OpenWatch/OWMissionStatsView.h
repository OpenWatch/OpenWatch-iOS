//
//  OWMissionStatsView.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 8/13/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWMission.h"

@interface OWMissionStatsView : UIView

@property (nonatomic, strong) UIImageView *peopleImageView;
@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UILabel *mediaCountLabel;
@property (nonatomic, strong) UILabel *peopleCountLabel;

@property (nonatomic, strong) OWMission *mission;

@end
