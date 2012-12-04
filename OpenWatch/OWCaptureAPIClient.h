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

- (void) startedRecording:(NSManagedObjectID*)recordingObjectID;
- (void) uploadFileURL:(NSURL*)url recording:(NSManagedObjectID*)recordingObjectID priority:(NSOperationQueuePriority)priority;
- (void) finishedRecording:(NSManagedObjectID*)recordingObjectID;
- (void) updateMetadataForRecording:(NSManagedObjectID*)recordingObjectID;

@end
