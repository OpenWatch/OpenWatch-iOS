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
#import "OWPreviewView.h"

#define PADDING 5.0f

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

+ (CGFloat) cellHeight {
    return 260.0f;
}

+ (CGFloat) cellWidth {
    return 320.0f;
}

- (void) setupTitleLabel {
    CGFloat titleLabelXOrigin = PADDING;
    CGFloat titleLabelWidth = [OWMediaObjectTableViewCell cellWidth] / 2;
    CGFloat titleLabelHeight = 25.0f;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelXOrigin, [OWUtilities bottomOfView:thumbnailImageView] + PADDING, titleLabelWidth, titleLabelHeight)];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [self.contentView addSubview:titleLabel];
}

- (void) setupThumbnailImageView {
    CGFloat imageWidth = [OWMediaObjectTableViewCell cellWidth] - PADDING * 2;
    CGFloat imageHeight = [OWPreviewView heightForWidth:imageWidth];
    self.thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, imageWidth, imageHeight)];
    
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnailImageView.layer.masksToBounds = YES;
    self.thumbnailImageView.layer.shouldRasterize = YES;
    self.thumbnailImageView.backgroundColor = [UIColor lightGrayColor];
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingIndicator.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    
    CGFloat typeWidth = 20.0f;
    CGFloat typeHeight = 20.0f;
    self.mediaTypeImageView = [[UIImageView alloc] initWithFrame:CGRectMake([OWMediaObjectTableViewCell cellWidth] - PADDING - typeWidth, [OWUtilities bottomOfView:self.thumbnailImageView], typeWidth, typeHeight)];
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
    
    NSString *title = mediaObject.title;
    
    if (title.length == 0) {
        NSDateFormatter *dateFormatter = [OWUtilities humanizedDateFormatter];
        if (mediaObject.firstPostedDate) {
            self.titleLabel.text = [dateFormatter stringFromDate:mediaObject.firstPostedDate];
        } else if (mediaObject.modifiedDate) {
            self.titleLabel.text = [dateFormatter stringFromDate:mediaObject.modifiedDate];
        } else {
            self.titleLabel.text = @"Untitled";
        }
    } else {
        self.titleLabel.text = title;
    }
    
    
    if (!mediaObject.thumbnailURL || mediaObject.thumbnailURL.absoluteString.length == 0) {
        NSLog(@"No thumbnail!");
    }
    
    UIImage *placeholderImage = [mediaObject placeholderThumbnailImage];
    self.mediaTypeImageView.image = [mediaObject mediaTypeImage];
    

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
