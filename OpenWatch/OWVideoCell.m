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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupVideoPreview];        
    }
    return self;
}


- (void) setupVideoPreview {
    CGFloat width = [OWMediaObjectTableViewCell cellWidth];
    CGFloat height = [OWPreviewView heightForWidth:width];
    CGRect frame = CGRectMake(0, 0, width, height);
    self.videoPreview = [[OWVideoPreview alloc] initWithFrame:frame];
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
