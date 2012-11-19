//
//  OWRecording.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    OWFileUploadStateUnknown = 0,
    OWFileUploadStateUploading,
    OWFileUploadStateFailed,
    OWFileUploadStateCompleted,
    OWFileUploadStateRecording
} OWFileUploadState;

@interface OWRecording : NSObject

@property (nonatomic, strong, readonly) NSString *uuid;
@property (nonatomic, strong, readonly) NSString *recordingPath;
@property (nonatomic, strong, readonly) NSDate *startDate;
@property (nonatomic, strong, readonly) NSDate *endDate;
@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) CLLocation *location;

- (id) initWithRecordingPath:(NSString*)path;
- (void) setUploadState:(OWFileUploadState)uploadState forFileAtURL:(NSURL*)url;
- (OWFileUploadState)uploadStateForFileAtURL:(NSURL*)url;
- (void) saveMetadata;

- (NSArray*) failedFileUploadURLs;
- (NSUInteger) failedFileUploadCount;

- (void) startRecording;
- (void) stopRecording;

- (NSDictionary*) dictionaryRepresentation;

- (NSURL*) urlForNextSegment;
- (NSURL*) highQualityURL;

@end
