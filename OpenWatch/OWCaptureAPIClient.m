//
//  OWCaptureAPIClient.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWCaptureAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "OWRecordingController.h"
#import "OWSettingsController.h"
#import "OWUtilities.h"
#import "OWLocalMediaController.h"
#import "OWAccountAPIClient.h"

#define kUploadStateStart @"start"
#define kUploadStateUpload @"upload"
#define kUploadStateEnd @"end"
#define kUploadStateMetadata @"update_metadata"
#define kUploadStateUploadHQ @"upload_hq"

@implementation OWCaptureAPIClient

+ (OWCaptureAPIClient *)sharedClient {
    static OWCaptureAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[OWCaptureAPIClient alloc] initWithBaseURL:[NSURL URLWithString:[OWUtilities captureBaseURLString]]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    self.parameterEncoding = AFJSONParameterEncoding;    
    
    //NSLog(@"maxConcurrentOperations: %d", self.operationQueue.maxConcurrentOperationCount);
    //self.operationQueue.maxConcurrentOperationCount = 1;
        
    return self;
}

- (void) updateMetadataForRecording:(NSManagedObjectID*)recordingObjectID callback:(void (^)(BOOL success))callback {
    NSString *postPath = [self postPathForRecording:recordingObjectID uploadState:kUploadStateMetadata];
    [self uploadMetadataForRecording:recordingObjectID postPath:postPath callback:callback retryCount:kOWCaptureAPIClientDefaultRetryCount];
}


// This is the worst function of all time
- (void) uploadFailedFileURLs:(NSArray*)failedFileURLs forRecording:(NSManagedObjectID*)recordingObjectID {
    OWLocalMediaObject *localObject = [OWLocalMediaController localMediaObjectForObjectID:recordingObjectID];
    
    Class objectClass = [localObject class];
    NSString *uuid = localObject.uuid;
    
    [[OWAccountAPIClient sharedClient] getObjectWithUUID:uuid objectClass:objectClass success:^(NSManagedObjectID *objectID) {
        [[OWCaptureAPIClient sharedClient] finishedRecording:recordingObjectID callback:^(BOOL success) {
            NSLog(@"[Sync] Simulated Finished Recording for %@, success: %d", uuid, success);
            for (NSURL *url in failedFileURLs) {
                [[OWCaptureAPIClient sharedClient] uploadFileURL:url recording:recordingObjectID priority:NSOperationQueuePriorityVeryLow retryCount:kOWCaptureAPIClientDefaultRetryCount];
            }
        }];
    } failure:^(NSString *reason) {
        NSLog(@"[Sync] Recording %@ not found in Django: %@", uuid, reason);
        [[OWCaptureAPIClient sharedClient] startedRecording:recordingObjectID callback:^(BOOL success) {
            NSLog(@"[Sync] Simulated Started Recording for %@, success: %d", uuid, success);
            [[OWCaptureAPIClient sharedClient] finishedRecording:recordingObjectID callback:^(BOOL success) {
                NSLog(@"[Sync] Simulated Finished Recording for %@, success: %d", uuid, success);
                [[OWCaptureAPIClient sharedClient] updateMetadataForRecording:recordingObjectID callback:^(BOOL success) {
                    NSLog(@"[Sync] Simulated Update Metadata for %@, success: %d", uuid, success);

                    [[OWAccountAPIClient sharedClient] postObjectWithUUID:uuid objectClass:objectClass success:^{
                        NSLog(@"[Sync] Success Django Metadata for %@", uuid);
                    } failure:^(NSString *reason) {
                        NSLog(@"[Sync] Failed Django Metadata for %@: %@", uuid, reason);
                    } retryCount:kOWAccountAPIClientDefaultRetryCount];
                    
                    for (NSURL *url in failedFileURLs) {
                        [[OWCaptureAPIClient sharedClient] uploadFileURL:url recording:recordingObjectID priority:NSOperationQueuePriorityVeryLow retryCount:kOWCaptureAPIClientDefaultRetryCount];
                    }
                }];
            }];
        }];
    } retryCount:kOWAccountAPIClientDefaultRetryCount];
}

- (void) uploadFileURL:(NSURL*)url recording:(NSManagedObjectID*)recordingObjectID priority:(NSOperationQueuePriority)priority retryCount:(NSUInteger)retryCount {
    OWLocalRecording *recording = [OWRecordingController localRecordingForObjectID:recordingObjectID];
    
    NSLog(@"Uploading file (%d): %@", retryCount, url.absoluteString);
    
    if (retryCount <= 0) {
        [recording setUploadState:OWFileUploadStateFailed forFileAtURL:url];

        NSLog(@"Total retry failure to file: %@", url.absoluteString);
        return;
    }
    
    if (!recording) {
        NSLog(@"Recording not found! AHhhhhh!!!");
        return;
    }
    [recording setUploadState:OWFileUploadStateUploading forFileAtURL:url];
    NSString *postPath = nil;
    if ([[url lastPathComponent] isEqualToString:@"hq.mp4"]) {
        postPath = [self postPathForRecording:recording.objectID uploadState:kUploadStateUploadHQ];
    } else {
        postPath = [self postPathForRecording:recording.objectID uploadState:kUploadStateUpload];
    }

    NSLog(@"POSTing (%d) %@ to %@", retryCount, url.absoluteString, postPath);

    NSURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:postPath parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {        
        NSError *error = nil;
        [formData appendPartWithFileURL:url name:@"upload" error:&error];
        if (error) {
            NSLog(@"Error appending part file URL %@: %@%@", url, [error localizedDescription], [error userInfo]);
            [recording setUploadState:OWFileUploadStateFailed forFileAtURL:url];
            [self uploadFileURL:url recording:recordingObjectID priority:priority retryCount:retryCount - 1];
        }
    }];
    if (!request) {
        NSLog(@"Request for %@ nil!", url.absoluteString);
        [recording setUploadState:OWFileUploadStateFailed forFileAtURL:url];
        [self uploadFileURL:url recording:recordingObjectID priority:priority retryCount:retryCount - 1];
        return;
    }
    
    __block NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    
    AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"File upload response %@: %@", url.absoluteString, responseObject);
        BOOL successValue = NO;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            successValue = [[responseObject objectForKey:@"success"] boolValue];
        }
        if (!successValue) {
            NSLog(@"Success is not true for %@: %@", url.absoluteString, responseObject);
            [self uploadFileURL:url recording:recordingObjectID priority:priority retryCount:retryCount - 1];
        } else {
            OWLocalRecording *localRecording = [OWRecordingController localRecordingForObjectID:recordingObjectID];
            NSDate *endDate = [NSDate date];
            NSTimeInterval endTime = [endDate timeIntervalSince1970];
            NSTimeInterval diff = endTime - startTime;
            NSError *error = nil;
            unsigned long long length = [[[NSFileManager defaultManager] attributesOfItemAtPath:[url path] error:&error] fileSize];
            if (error) {
                NSLog(@"Error getting size of URL: %@%@", [error localizedDescription], [error userInfo]);
                error = nil;
            }
            double bps = (length * 8.0) / diff;
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
            [userInfo setObject:[NSNumber numberWithDouble:bps] forKey:@"bps"];
            [userInfo setObject:endDate forKey:@"endDate"];
            [userInfo setObject:url forKey:@"fileURL"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kOWCaptureAPIClientBandwidthNotification object:nil userInfo:userInfo];
            [localRecording setUploadState:OWFileUploadStateCompleted forFileAtURL:url];
            NSLog(@"timeSpent: %f fileLength: %lld, %f bits/sec", diff, length, bps);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to POST %@ to %@: %@", url.absoluteString, postPath, error.userInfo);
        [self uploadFileURL:url recording:recordingObjectID priority:priority retryCount:retryCount - 1];
    }];
    
    [self enqueueHTTPRequestOperation:operation]; 
}

- (void) finishedRecording:(NSManagedObjectID*)recordingObjectID callback:(void (^)(BOOL success))callback {
    NSLog(@"Finishing (POSTing) recording...");
    NSString *postPath = [self postPathForRecording:recordingObjectID uploadState:kUploadStateEnd];
    [self uploadMetadataForRecording:recordingObjectID postPath:postPath callback:callback retryCount:kOWCaptureAPIClientDefaultRetryCount];
}

- (void) startedRecording:(NSManagedObjectID*)recordingObjectID callback:(void (^)(BOOL success))callback {
    NSString *postPath = [self postPathForRecording:recordingObjectID uploadState:kUploadStateStart];
    [self uploadMetadataForRecording:recordingObjectID postPath:postPath callback:callback retryCount:kOWCaptureAPIClientDefaultRetryCount];
}



- (void) uploadMetadataForRecording:(NSManagedObjectID*)recordingObjectID postPath:(NSString*)postPath callback:(void (^)(BOOL success))callback retryCount:(NSUInteger)retryCount {
    OWLocalRecording *recording = [OWRecordingController localRecordingForObjectID:recordingObjectID];
    NSDictionary *params = recording.metadataDictionary;
    
    NSLog(@"Updating Metadata (%d): %@", retryCount, postPath);
    
    if (retryCount <= 0) {
        if (callback) {
            NSLog(@"Total failure.");
            callback(NO);
        }
    } else {
        [self postPath:postPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"metadata response: %@", [responseObject description]);
            BOOL successValue = NO;
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                successValue = [[responseObject objectForKey:@"success"] boolValue];
                if (callback && successValue) {
                    callback(YES);
                }
            }
            
            if (!successValue) {
                [self uploadMetadataForRecording:recordingObjectID postPath:postPath callback:callback retryCount:retryCount - 1];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error pushing metadata: %@%@", [error localizedDescription], [error userInfo]);
            
            [self uploadMetadataForRecording:recordingObjectID postPath:postPath callback:callback retryCount:retryCount - 1];
        }];
    }
}

- (NSString*) postPathForRecording:(NSManagedObjectID*)recordingObjectID uploadState:(NSString*)state {
    OWLocalRecording *recording = [OWRecordingController localRecordingForObjectID:recordingObjectID];
    OWSettingsController *settingsController = [OWSettingsController sharedInstance];
    NSString *publicUploadToken = settingsController.account.publicUploadToken;
    NSString *uploadPath = [NSString stringWithFormat:@"/%@/%@/%@", state, publicUploadToken, recording.uuid];
    return uploadPath;
}


@end
