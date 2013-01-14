//
//  OWMediaObjectTableViewCell.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWMediaObject.h"
#import "OWTallyView.h"

@interface OWMediaObjectTableViewCell : UITableViewCell

@property (nonatomic, strong) NSManagedObjectID *mediaObjectID;

@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) OWTallyView *tallyView;
@property (nonatomic, strong) UILabel *dateModifiedLabel;
@property (nonatomic) BOOL isLocalRecording;

@end
