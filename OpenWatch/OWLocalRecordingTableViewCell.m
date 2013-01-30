//
//  OWLocalRecordingTableViewCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 1/30/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWLocalRecordingTableViewCell.h"
#import "OWUtilities.h"
#import "OWLocalRecording.h"

#define PADDING 10.0f

@implementation OWLocalRecordingTableViewCell
@synthesize dateCreatedLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupDateCreatedLabel];
    }
    return self;
}

- (void) setupDateCreatedLabel {
    CGFloat dateModifiedWidth = 180.0f;
    CGFloat dateModifiedHeight = 20.0f;
    self.dateCreatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-dateModifiedWidth-PADDING, self.contentView.frame.size.height-dateModifiedHeight-PADDING, dateModifiedWidth, dateModifiedHeight)];
    self.dateCreatedLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [OWUtilities styleLabel:dateCreatedLabel];
    dateCreatedLabel.textColor = [OWUtilities greyColorWithGreyness:0.5f];
    self.dateCreatedLabel.textAlignment = UITextAlignmentRight;
    [self.contentView addSubview:dateCreatedLabel];
}

- (void) setMediaObjectID:(NSManagedObjectID *)mediaObjectID {
    [super setMediaObjectID:mediaObjectID];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context objectWithID:mediaObjectID];
    OWLocalRecording *recording = (OWLocalRecording*)mediaObject;
    NSDateFormatter *dateFormatter = [OWUtilities humanizedDateFormatter];
    self.dateCreatedLabel.text = [dateFormatter stringFromDate:recording.startDate];
}

@end
