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

- (void) startedRecording:(OWLocalRecording*)recording;
- (void) uploadFileURL:(NSURL*)url recording:(OWLocalRecording*)recording priority:(NSOperationQueuePriority)priority;
- (void) finishedRecording:(OWLocalRecording*)recording;
- (void) updateMetadataForRecording:(OWLocalRecording*)recording;

@end
