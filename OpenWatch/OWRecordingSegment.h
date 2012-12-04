//
//  OWRecordingSegment.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OWLocalRecording;

typedef enum {
    OWFileUploadStateUnknown = 0,
    OWFileUploadStateUploading,
    OWFileUploadStateFailed,
    OWFileUploadStateCompleted,
    OWFileUploadStateRecording
} OWFileUploadState;

@interface OWRecordingSegment : NSManagedObject

@property (nonatomic, retain) NSString * filePath;
@property (nonatomic) OWFileUploadState fileUploadState;
@property (nonatomic, retain) OWLocalRecording *recording;

@end
