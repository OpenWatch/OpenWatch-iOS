//
//  OWThumbnailCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/17/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWThumbnailCell.h"
#import <QuartzCore/QuartzCore.h>
#import "OWPreviewView.h"
#import "OWUtilities.h"
#import "UIImageView+AFNetworking.h"

#define PADDING 5.0f

@implementation OWThumbnailCell
@synthesize loadingIndicator, thumbnailImageView;

- (void) setupPreviewView {
    [self setupThumbnailImageView];
}

- (void) setupThumbnailImageView {
    CGFloat imageWidth = [OWMediaObjectTableViewCell cellWidth];
    CGFloat imageHeight = [OWPreviewView heightForWidth:imageWidth];
    self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
    
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnailImageView.layer.masksToBounds = YES;
    self.thumbnailImageView.layer.shouldRasterize = YES;
    self.thumbnailImageView.backgroundColor = [UIColor lightGrayColor];
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingIndicator.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    
        
    [self.thumbnailImageView addSubview:loadingIndicator];
    [self.contentView addSubview:thumbnailImageView];
    
    self.previewView = thumbnailImageView;
}

- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    [super setMediaObjectID:newMediaObjectID];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context existingObjectWithID:self.mediaObjectID error:nil];

    [self.loadingIndicator stopAnimating];
    if (!mediaObject.thumbnailURL || mediaObject.thumbnailURL.absoluteString.length == 0) {
        NSLog(@"No thumbnail!");
    }
    UIImage *placeholderImage = [mediaObject placeholderThumbnailImage];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:mediaObject.thumbnailURL];
    __weak OWThumbnailCell *weakSelf = self;
    [loadingIndicator startAnimating];
    [self.thumbnailImageView setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.thumbnailImageView.image = image;
        [weakSelf.loadingIndicator stopAnimating];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakSelf.loadingIndicator stopAnimating];
        NSLog(@"Failed to load thumbnail from URL: %@ %@", mediaObject.thumbnailURL, [error userInfo]);
    }];
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
