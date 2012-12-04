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

static NSString * const kOWCaptureAPIClientAPIBaseURLString = @"http://192.168.1.44:5000/";

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
        _sharedClient = [[OWCaptureAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kOWCaptureAPIClientAPIBaseURLString]];
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
    
    [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [[OWRecordingController sharedInstance] scanRecordingsForUnsubmittedData];
            });
        }
    }];
    
    
    //NSLog(@"maxConcurrentOperations: %d", self.operationQueue.maxConcurrentOperationCount);
    //self.operationQueue.maxConcurrentOperationCount = 1;
        
    return self;
}

- (void) updateMetadataForRecording:(NSManagedObjectID*)recordingObjectID {
    NSString *postPath = [self postPathForRecording:recordingObjectID uploadState:kUploadStateMetadata];
    [self uploadMetadataForRecording:recordingObjectID postPath:postPath];
}

- (void) uploadFileURL:(NSURL*)url recording:(NSManagedObjectID*)recordingObjectID priority:(NSOperationQueuePriority)priority {
    OWLocalRecording *recording = [self recordingForObjectID:recordingObjectID];
    if (!recording) {
        return;
    }
    if (self.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable || self.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        [recording setUploadState:OWFileUploadStateFailed forFileAtURL:url];
        return;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setObject:@"test" forKey:@"title"];
    [parameters setObject:recording.uuid forKey:@"uid"];
    [recording setUploadState:OWFileUploadStateUploading forFileAtURL:url];
    NSString *postPath = nil;
    if ([[url lastPathComponent] isEqualToString:@"hq.mp4"]) {
        postPath = [self postPathForRecording:recording.objectID uploadState:kUploadStateUploadHQ];
    } else {
        postPath = [self postPathForRecording:recording.objectID uploadState:kUploadStateUpload];
    }



    NSURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:postPath parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
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
        OWLocalRecording *localRecording = [self recordingForObjectID:recordingObjectID];
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
        [recording setUploadState:OWFileUploadStateFailed forFileAtURL:url];
    }];
    
    [self enqueueHTTPRequestOperation:operation]; 
}

- (void) finishedRecording:(NSManagedObjectID*)recordingObjectID {
    NSString *postPath = [self postPathForRecording:recordingObjectID uploadState:kUploadStateEnd];
    [self uploadMetadataForRecording:recordingObjectID postPath:postPath];
}

- (void) startedRecording:(NSManagedObjectID*)recordingObjectID {
    NSString *postPath = [self postPathForRecording:recordingObjectID uploadState:kUploadStateStart];
    [self uploadMetadataForRecording:recordingObjectID postPath:postPath];
}

- (OWLocalRecording*) recordingForObjectID:(NSManagedObjectID*)objectID {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSError *error = nil;
    OWLocalRecording *recording = (OWLocalRecording*)[context existingObjectWithID:objectID error:&error];
    if (error) {
        NSLog(@"Error: %@", [error userInfo]);
        error = nil;
    }
    return recording;
}


- (void) uploadMetadataForRecording:(NSManagedObjectID*)recordingObjectID postPath:(NSString*)postPath  {
    OWLocalRecording *recording = [self recordingForObjectID:recordingObjectID];
    NSDictionary *params = recording.dictionaryRepresentation;
    [self postPath:postPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"metadata response: %@", [responseObject description]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error pushing metadata: %@%@", [error localizedDescription], [error userInfo]);
    }];
}

- (NSString*) postPathForRecording:(NSManagedObjectID*)recordingObjectID uploadState:(NSString*)state {
    OWLocalRecording *recording = [self recordingForObjectID:recordingObjectID];
    OWSettingsController *settingsController = [OWSettingsController sharedInstance];
    NSString *publicUploadToken = settingsController.account.publicUploadToken;
    NSString *uploadPath = [NSString stringWithFormat:@"/%@/%@/%@", state, publicUploadToken, recording.uuid];
    return uploadPath;
}


@end
