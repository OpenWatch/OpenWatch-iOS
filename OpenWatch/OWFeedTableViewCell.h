//
//  OWFeedTableViewCell.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/30/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWMediaObjectTableViewCell.h"
#import "OWTallyView.h"

@interface OWFeedTableViewCell : OWMediaObjectTableViewCell

@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) OWTallyView *tallyView;

@end
