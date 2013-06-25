//
//  OWRecordingSegment.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "_OWRecordingSegment.h"

@class OWLocalRecording;

typedef enum {
    OWFileUploadStateUnknown = 0,
    OWFileUploadStateUploading = 1,
    OWFileUploadStateFailed = 2,
    OWFileUploadStateCompleted = 3,
    OWFileUploadStateRecording = 4
} OWFileUploadState;

@interface OWRecordingSegment : _OWRecordingSegment

@property (nonatomic) OWFileUploadState fileUploadState;

@end
