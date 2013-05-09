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
        self.photoScrollView.minimumZoomScale=1.0;
        self.photoScrollView.maximumZoomScale=6.0;
        self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.photoImageView = [[UIImageView alloc] init];
        self.photoScrollView.delegate = self;
    }
    return self;
}

- (void) setPhoto:(OWPhoto *)newPhoto {
    photo = newPhoto;
    
    self.title = photo.title;
    
    if ([photo localMediaPath].length > 0) {
        [self.photoImageView setImage:[photo localImage]];
        [self refreshFrames];
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[photo remoteMediaURL]];
        __block OWPhotoDetailViewController *weakSelf = self;
        [self.photoImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakSelf.photoImageView.image = image;
            [weakSelf refreshFrames];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"Failed to load image: %@", error.userInfo);
        }];
    }
}

- (void) refreshFrames {
    self.photoImageView.frame = CGRectMake(0, 0, self.photoImageView.image.size.width, self.photoImageView.image.size.height);
    self.photoScrollView.contentSize = CGSizeMake(self.photoImageView.image.size.width, self.photoImageView.image.size.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view addSubview:photoScrollView];
    [self.photoScrollView addSubview:photoImageView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoImageView;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.photoScrollView.frame = self.view.bounds;
    self.photoImageView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
