//
//  OWCaptureAPIClient.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "OWLocalRecording.h"

#define kOWCaptureAPIClientBandwidthNotification @"kOWCaptureAPIClientBandwidthNotification"

@interface OWCaptureAPIClient : AFHTTPClient

+ (OWCaptureAPIClient *)sharedClient;

@property (nonatomic, strong) NSMutableDictionary *uploadDictionary;

- (void) startedRecording:(NSManagedObjectID*)recordingObjectID callback:(void (^)(BOOL success))callback;
- (void) uploadFileURL:(NSURL*)url recording:(NSManagedObjectID*)recordingObjectID priority:(NSOperationQueuePriority)priority;
- (void) uploadFailedFileURLs:(NSArray*)failedFileURLs forRecording:(NSManagedObjectID*)recordingObjectID;
- (void) finishedRecording:(NSManagedObjectID*)recordingObjectID callback:(void (^)(BOOL success))callback;
- (void) updateMetadataForRecording:(NSManagedObjectID*)recordingObjectID callback:(void (^)(BOOL success))callback;

@end
