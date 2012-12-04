//
//  OWRecordingSegment.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWRecordingSegment.h"
#import "OWLocalRecording.h"

@interface OWRecordingSegment()
@property (nonatomic, retain) NSNumber * uploadState;
@end

@implementation OWRecordingSegment

@dynamic filePath;
@dynamic uploadState;
@dynamic recording;

- (OWFileUploadState) fileUploadState {
    return [self.uploadState unsignedIntegerValue];
}

- (void) setFileUploadState:(OWFileUploadState)fileUploadState {
    self.uploadState = @(fileUploadState);
}


@end
