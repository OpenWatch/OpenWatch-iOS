//
//  OWPhotoDetailViewController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/7/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWPhotoDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface OWPhotoDetailViewController ()

@end

@implementation OWPhotoDetailViewController
@synthesize photo, photoImageView, photoScrollView;

- (id)init
{
    self = [super init];
    if (self) {
        self.photoScrollView = [[UIScrollView alloc] init];
        self.photoImageView = [[UIImageView alloc] init];
    }
    return self;
}

- (void) setPhoto:(OWPhoto *)newPhoto {
    photo = newPhoto;
    
    if ([photo localMediaPath].length > 0) {
        [self.photoImageView setImage:[photo localImage]];
    } else {
        [self.photoImageView setImageWithURL:photo.remoteMediaURL];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
