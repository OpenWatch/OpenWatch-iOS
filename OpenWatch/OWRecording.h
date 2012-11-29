//
//  OWRecording.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "OWLocationControler.h"

typedef enum {
    OWFileUploadStateUnknown = 0,
    OWFileUploadStateUploading,
    OWFileUploadStateFailed,
    OWFileUploadStateCompleted,
    OWFileUploadStateRecording
} OWFileUploadState;

@interface OWRecording : NSObject <OWLocationControlerDelegate> {
    
}

@property (nonatomic, strong, readonly) NSString *uuid;
@property (nonatomic, strong, readonly) NSString *recordingPath;
@property (nonatomic, strong, readonly) NSDate *startDate;
@property (nonatomic, strong, readonly) NSDate *endDate;
@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *recordingDescription;
@property (nonatomic, strong) CLLocation *startLocation;
@property (nonatomic, strong) CLLocation *endLocation;

- (id) initWithRecordingPath:(NSString*)path;
- (void) setUploadState:(OWFileUploadState)uploadState forFileAtURL:(NSURL*)url;
- (OWFileUploadState)uploadStateForFileAtURL:(NSURL*)url;
- (void) saveMetadata;

- (NSArray*) failedFileUploadURLs;
- (NSUInteger) failedFileCount;
- (NSUInteger) completedFileCount;
- (NSUInteger) recordingFileCount;
- (NSUInteger) uploadingFileCount;
- (NSUInteger) totalFileCount;
- (BOOL) isHighQualityFileUploaded;


- (void) startRecording;
- (void) stopRecording;

- (NSDictionary*) dictionaryRepresentation;

- (NSURL*) urlForNextSegment;
- (NSURL*) highQualityURL;

@end
