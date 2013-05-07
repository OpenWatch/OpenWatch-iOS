//
//  OWLocalRecording.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OWManagedRecording.h"
#import "OWRecordingSegment.h"
#import "OWLocationController.h"
#import "_OWLocalRecording.h"

@interface OWLocalRecording : _OWLocalRecording <OWLocationControllerDelegate>

+ (OWLocalRecording*) recordingWithUUID:(NSString*)uuid;
+ (OWLocalRecording*) recording;
- (void) setUploadState:(OWFileUploadState)uploadState forFileAtURL:(NSURL*)url;
- (OWFileUploadState)uploadStateForFileAtURL:(NSURL*)url;

- (NSString*) localRecordingPath;
- (NSArray*) failedFileUploadURLs;
- (NSUInteger) failedFileCount;
- (NSUInteger) completedFileCount;
- (NSUInteger) totalFileCount;
- (BOOL) isHighQualityFileUploaded;


- (void) startRecording;
- (void) stopRecording;

- (NSURL*) urlForNextSegmentWithCount:(NSUInteger)count;
- (NSURL*) highQualityURL;

@end