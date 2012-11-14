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

static NSString * const kOWCaptureAPIClientAPIBaseURLString = @"http://192.168.1.44:5000/";

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
    
    [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN) {
            [[OWRecordingController sharedInstance] scanRecordingsForUnsubmittedData];
        }
    }];
    
    //NSLog(@"maxConcurrentOperations: %d", self.operationQueue.maxConcurrentOperationCount);
    self.operationQueue.maxConcurrentOperationCount = 1;
        
    return self;
}

- (void) testUpload {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"testdata" withExtension:@"png"];
    //[self uploadFileURL:url recording:nil];
}

- (void) uploadFileURL:(NSURL*)url recording:(OWRecording*)recording priority:(NSOperationQueuePriority)priority {
    if (self.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable || self.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        [recording setUploadState:OWFileUploadStateFailed forFileAtURL:url];
        return;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setObject:@"test" forKey:@"title"];
    [parameters setObject:recording.uuid forKey:@"uid"];
    NSString *uploadPath = [NSString stringWithFormat:@"/upload/%@", recording.uuid];
    [recording setUploadState:OWFileUploadStateUploading forFileAtURL:url];
    NSURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:uploadPath parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:url name:@"upload" error:&error];
        if (error) {
            NSLog(@"Error appending part file URL: %@%@", [error localizedDescription], [error userInfo]);
        }
    }];
    
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.queuePriority = priority;
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        //NSLog(@"%d: %lld/%lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        if (totalBytesWritten >= totalBytesExpectedToWrite) {
            NSDate *endDate = [NSDate date];
            NSTimeInterval endTime = [endDate timeIntervalSince1970];
            NSTimeInterval diff = endTime - startTime;
            double bps = totalBytesWritten * 8 / diff;
            NSLog(@"%f bits/sec", bps);
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
            [userInfo setObject:[NSNumber numberWithDouble:bps] forKey:@"bps"];
            [userInfo setObject:endDate forKey:@"endDate"];
            [userInfo setObject:url forKey:@"fileURL"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kOWCaptureAPIClientBandwidthNotification object:nil userInfo:userInfo];
        }
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"success: %@", operation.responseString);
        [recording setUploadState:OWFileUploadStateCompleted forFileAtURL:url];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@%@ %@", [error localizedDescription], [error userInfo], operation.responseString);
        [recording setUploadState:OWFileUploadStateFailed forFileAtURL:url];
    }];
    //NSLog(@"Queued operations: %d", self.operationQueue.operationCount);
    [self enqueueHTTPRequestOperation:operation];
}

- (void) finishedRecording:(OWRecording*)recording {
    /* do this properly
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.operationQueue waitUntilAllOperationsAreFinished];
        NSString *postPath = [NSString stringWithFormat:@"/end/%@", uuid];
        [self postPath:postPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"end response: %@", [responseObject description]);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error finishing recording on server: %@%@", [error localizedDescription], [error userInfo]);
        }];
    });
    */
    
}


@end
