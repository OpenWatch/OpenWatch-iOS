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
    
    responseQueue = dispatch_queue_create("Response Queue", DISPATCH_QUEUE_SERIAL);
    requestQueue = dispatch_queue_create("Request Queue", DISPATCH_QUEUE_SERIAL);
    
    
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

- (void) testUpload {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"testdata" withExtension:@"png"];
    //[self uploadFileURL:url recording:nil];
}

- (void) uploadFileURL:(NSURL*)url recording:(OWRecording*)recording priority:(NSOperationQueuePriority)priority {
    dispatch_async(requestQueue, ^{
        NSTimeInterval before = [[NSDate date] timeIntervalSince1970];

        if (self.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable || self.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
            [recording setUploadState:OWFileUploadStateFailed forFileAtURL:url];
            return;
        }
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
        [parameters setObject:@"test" forKey:@"title"];
        [parameters setObject:recording.uuid forKey:@"uid"];
        [recording setUploadState:OWFileUploadStateUploading forFileAtURL:url];
        NSString *postPath = [self postPathForRecording:recording uploadState:kUploadStateUpload];


        NSURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:postPath parameters:parameters constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
            //NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"openwatch" ofType:@"png"]];
            
            NSError *error = nil;
            [formData appendPartWithFileURL:url name:@"upload" error:&error];

            if (error) {
                NSLog(@"Error appending part file URL: %@%@", [error localizedDescription], [error userInfo]);
            }
             
        }];
        

        
        NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.successCallbackQueue = responseQueue;
        operation.failureCallbackQueue = responseQueue;
        //operation.queuePriority = priority;
        /*
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            
            dispatch_async(responseQueue, ^{
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
            });
            
        }];
         */
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"success: %@", operation.responseString);
            [recording setUploadState:OWFileUploadStateCompleted forFileAtURL:url];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [recording setUploadState:OWFileUploadStateFailed forFileAtURL:url];
        }];
        //NSLog(@"Queued operations: %d", self.operationQueue.operationCount);
        
        [self enqueueHTTPRequestOperation:operation];
        NSTimeInterval after = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval diff = after-before;
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        NSLog(@"timeSpent: %f fileLength: %d", diff, [data length]);
    });
}

- (void) finishedRecording:(OWRecording*)recording {
    NSString *postPath = [self postPathForRecording:recording uploadState:kUploadStateEnd];
    [self uploadMetadataForRecording:recording postPath:postPath];
}

- (void) startedRecording:(OWRecording*)recording {
    NSString *postPath = [self postPathForRecording:recording uploadState:kUploadStateStart];
    [self uploadMetadataForRecording:recording postPath:postPath];
}


- (void) uploadMetadataForRecording:(OWRecording*)recording postPath:(NSString*)postPath  {
    dispatch_async(requestQueue, ^{
        NSDictionary *params = recording.dictionaryRepresentation;
        [self postPath:postPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"metadata response: %@", [responseObject description]);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error pushing metadata: %@%@", [error localizedDescription], [error userInfo]);
        }];
    });
}

- (NSString*) postPathForRecording:(OWRecording*)recording uploadState:(NSString*)state {
    OWSettingsController *settingsController = [OWSettingsController sharedInstance];
    NSString *publicUploadToken = settingsController.account.publicUploadToken;
    if (!publicUploadToken) {
        publicUploadToken = @"asdf";
    }
    NSString *uploadPath = [NSString stringWithFormat:@"/%@/%@/%@", state, publicUploadToken, recording.uuid];
    return uploadPath;
}


@end
