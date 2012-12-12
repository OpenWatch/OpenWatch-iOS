//
//  OWRecordingTableViewCell.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWRecordingTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation OWRecordingTableViewCell
@synthesize recording;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setRecording:(OWManagedRecording *)newRecording {
    recording = newRecording;
    [self.imageView setImageWithURL:[NSURL URLWithString:recording.thumbnailURL]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
