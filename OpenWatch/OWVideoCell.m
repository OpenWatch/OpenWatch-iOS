//
//  OWVideoCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/17/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWVideoCell.h"
#import "OWPreviewView.h"

@implementation OWVideoCell
@synthesize videoPreview;

- (void) setupPreviewView {
    [self setupVideoPreview];
}

- (void) setupVideoPreview {
    CGFloat width = [OWMediaObjectTableViewCell cellWidth];
    CGFloat height = [OWPreviewView heightForWidth:width];
    CGRect frame = CGRectMake(0, 0, width, height);
    self.videoPreview = [[OWVideoPreview alloc] initWithFrame:frame];
    self.videoPreview.clipsToBounds = YES;
    [self.contentView addSubview:videoPreview];
    self.previewView = videoPreview;
}


- (void) setMediaObjectID:(NSManagedObjectID *)newMediaObjectID {
    [super setMediaObjectID:newMediaObjectID];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context existingObjectWithID:self.mediaObjectID error:nil];

    if ([mediaObject isKindOfClass:[OWManagedRecording class]]) {
        self.videoPreview.video = (OWManagedRecording*)mediaObject;
    }
}
@end
