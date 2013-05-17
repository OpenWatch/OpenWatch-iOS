//
//  OWMediaObjectTableViewCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWMediaObjectTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "OWRecordingController.h"
#import "OWUser.h"
#import "OWStory.h"
#import "OWUtilities.h"
#import <QuartzCore/QuartzCore.h>
#import "OWStrings.h"
#import "OWAudio.h"
#import "OWPhoto.h"
#import "OWManagedRecording.h"
#import "OWInvestigation.h"

#define PADDING 10.0f

@implementation OWMediaObjectTableViewCell
@synthesize mediaObjectID, thumbnailImageView, titleLabel, loadingIndicator, mediaTypeImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupThumbnailImageView];
        [self setupTitleLabel];

        self.backgroundView = nil;
    }
    return self;
}

- (void) setupTitleLabel {
    CGFloat titleLabelXOrigin = [OWUtilities rightOfView:thumbnailImageView] + PADDING;
    CGFloat titleLabelWidth = self.contentView.frame.size.width - titleLabelXOrigin;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelXOrigin, 0, titleLabelWidth, 100)];
    self.titleLabel.numberOfLines = 3;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.contentView addSubview:titleLabel];
}

- (void) setupThumbnailImageView {
    CGFloat imageWidth = 100.0f;
    CGFloat imageHeight = imageWidth;
    self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, imageWidth, imageHeight)];
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.thumbnailImageView.layer.masksToBounds = YES;
    self.thumbnailImageView.layer.cornerRadius = 5.0;
    self.thumbnailImageView.layer.shouldRasterize = YES;
    self.thumbnailImageView.backgroundColor = [UIColor lightGrayColor];
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.loadingIndicator.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    
    CGFloat typeWidth = 20.0f;
    CGFloat typeHeight = 20.0f;
    self.mediaTypeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width - PADDING - typeWidth, self.contentView.frame.size.height - PADDING -  typeHeight, typeWidth, typeHeight)];
    self.mediaTypeImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.mediaTypeImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.thumbnailImageView addSubview:loadingIndicator];
    [self.contentView addSubview:mediaTypeImageView];
    [self.contentView addSubview:thumbnailImageView];
}


- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    mediaObjectID = newMediaObjectID;
    [self.loadingIndicator stopAnimating];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context existingObjectWithID:mediaObjectID error:nil];
    
    if (mediaObject.title.length == 0) {
        NSDateFormatter *dateFormatter = [OWUtilities humanizedDateFormatter];
        if (mediaObject.firstPostedDate) {
            self.titleLabel.text = [dateFormatter stringFromDate:mediaObject.firstPostedDate];
        }
    } else {
        self.titleLabel.text = mediaObject.title;
    }
    
    
    if (!mediaObject.thumbnailURL || mediaObject.thumbnailURL.absoluteString.length == 0) {
        NSLog(@"No thumbnail!");
    }
    
    UIImage *placeholderImage = nil;
    if ([mediaObject isKindOfClass:[OWAudio class]]) {
        placeholderImage = [UIImage imageNamed:@"saved-big.png"];
    } else if ([mediaObject isKindOfClass:[OWPhoto class]]) {
        placeholderImage = [UIImage imageNamed:@"image_placeholder.png"];
    } else if ([mediaObject isKindOfClass:[OWManagedRecording class]]){
        placeholderImage = [UIImage imageNamed:@"285-facetime.png"];
    } else if ([mediaObject isKindOfClass:[OWInvestigation class]]){
        placeholderImage = [UIImage imageNamed:@"166-newspaper.png"];
    } else {
        placeholderImage = [UIImage imageNamed:@"thumbnail_placeholder.png"];
    }
    
    self.mediaTypeImageView.image = placeholderImage;
    

    NSURLRequest *request = [NSURLRequest requestWithURL:mediaObject.thumbnailURL];
    __weak OWMediaObjectTableViewCell *weakSelf = self;
    [loadingIndicator startAnimating];
    [self.thumbnailImageView setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.thumbnailImageView.image = image;
        [weakSelf.loadingIndicator stopAnimating];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakSelf.loadingIndicator stopAnimating];
        NSLog(@"Failed to load thumbnail from URL: %@ %@", mediaObject.thumbnailURL, [error userInfo]);
    }];

    
}

@end
