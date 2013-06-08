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
    [self uploadMetadataForRecording:recordingObjectID postPath:postPath callback:callback];
}


// This is the worst function of all time
- (void) uploadFailedFileURLs:(NSArray*)failedFileURLs forRecording:(NSManagedObjectID*)recordingObjectID {
    OWLocalMediaObject *localObject = [OWLocalMediaController localMediaObjectForObjectID:recordingObjectID];
    
    Class objectClass = [localObject class];
    NSString *uuid = localObject.uuid;
    
    [[OWAccountAPIClient sharedClient] getObjectWithUUID:uuid objectClass:objectClass success:^(NSManagedObjectID *objectID) {
        for (NSURL *url in failedFileURLs) {
            [[OWCaptureAPIClient sharedClient] uploadFileURL:url recording:recordingObjectID priority:NSOperationQueuePriorityVeryLow];
        }
    } failure:^(NSString *reason) {
        NSLog(@"%@", reason);
        [[OWCaptureAPIClient sharedClient] startedRecording:recordingObjectID callback:^(BOOL success) {
            NSLog(@"success: %d", success);
            [[OWCaptureAPIClient sharedClient] finishedRecording:recordingObjectID callback:^(BOOL success) {
                NSLog(@"success: %d", success);
                [[OWCaptureAPIClient sharedClient] updateMetadataForRecording:recordingObjectID callback:^(BOOL success) {
                    NSLog(@"success: %d", success);
                    [[OWAccountAPIClient sharedClient] postObjectWithUUID:uuid objectClass:objectClass success:nil failure:nil];
                    
                    for (NSURL *url in failedFileURLs) {
                        [[OWCaptureAPIClient sharedClient] uploadFileURL:url recording:recordingObjectID priority:NSOperationQueuePriorityVeryLow];
                    }
                }];
            }];
        }];
    }];
}

- (void) uploadFileURL:(NSURL*)url recording:(NSManagedObjectID*)recordingObjectID priority:(NSOperationQueuePriority)priority {
    OWLocalRecording *recording = [OWRecordingController localRecordingForObjectID:recordingObjectID];
    if (!recording) {
        return;
    }
    if (self.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable || self.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        [recording setUploadState:OWFileUploadStateFailed forFileAtURL:url];
        return;
    }
    [recording setUploadState:OWFileUploadStateUploading forFileAtURL:url];
    NSString *postPath = nil;
    if ([[url lastPathComponent] isEqualToString:@"hq.mp4"]) {
        postPath = [self postPathForRecording:recording.objectID uploadState:kUploadStateUploadHQ];
    } else {
        postPath = [self postPathForRecording:recording.objectID uploadState:kUploadStateUpload];
    }

    NSLog(@"POSTing %@ to %@", url.absoluteString, postPath);

    NSURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:postPath parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
        //NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"openwatch" ofType:@"png"]];
        
        NSError *error = nil;
        [formData appendPartWithFileURL:url name:@"upload" error:&error];

        if (error) {
            NSLog(@"Error appending part file URL: %@%@", [error localizedDescription], [error userInfo]);
        }
         
    }];
    

    
    __block NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //operation.queuePriority = priority;
    /*
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        dispatch_async(responseQueue, ^{
            //NSLog(@"%d: %lld/%lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
            if (totalBytesWritten >= totalBytesExpectedToWrite) {

            }
        });
        
    }];
     */
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
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

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to POST %@ to %@: %@", url.absoluteString, postPath, error.userInfo);
        [recording setUploadState:OWFileUploadStateFailed forFileAtURL:url];
    }];
    
    [self enqueueHTTPRequestOperation:operation]; 
}

- (void) finishedRecording:(NSManagedObjectID*)recordingObjectID callback:(void (^)(BOOL success))callback {
    NSLog(@"Finishing (POSTing) recording...");
    NSString *postPath = [self postPathForRecording:recordingObjectID uploadState:kUploadStateEnd];
    [self uploadMetadataForRecording:recordingObjectID postPath:postPath callback:callback];
}

- (void) startedRecording:(NSManagedObjectID*)recordingObjectID callback:(void (^)(BOOL success))callback {
    NSString *postPath = [self postPathForRecording:recordingObjectID uploadState:kUploadStateStart];
    [self uploadMetadataForRecording:recordingObjectID postPath:postPath callback:callback];
}



- (void) uploadMetadataForRecording:(NSManagedObjectID*)recordingObjectID postPath:(NSString*)postPath callback:(void (^)(BOOL success))callback  {
    OWLocalRecording *recording = [OWRecordingController localRecordingForObjectID:recordingObjectID];
    NSDictionary *params = recording.metadataDictionary;
    NSLog(@"WTF: %@", [params description]);
    [self postPath:postPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"metadata response: %@", [responseObject description]);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if (callback) {
                callback([[responseObject objectForKey:@"success"] boolValue]);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error pushing metadata: %@%@", [error localizedDescription], [error userInfo]);
        if (callback) {
            callback(NO);
        }
    }];
}

- (NSString*) postPathForRecording:(NSManagedObjectID*)recordingObjectID uploadState:(NSString*)state {
    OWLocalRecording *recording = [OWRecordingController localRecordingForObjectID:recordingObjectID];
    OWSettingsController *settingsController = [OWSettingsController sharedInstance];
    NSString *publicUploadToken = settingsController.account.publicUploadToken;
    NSString *uploadPath = [NSString stringWithFormat:@"/%@/%@/%@", state, publicUploadToken, recording.uuid];
    return uploadPath;
}


@end
