//
//  OWPhotoDetailViewController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/7/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWPhoto.h"

@interface OWPhotoDetailViewController : UIViewController

@property (nonatomic, strong) UIScrollView *photoScrollView;
@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) OWPhoto *photo;

@end
