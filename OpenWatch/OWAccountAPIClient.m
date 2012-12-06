//
//  OWAccountAPIClient.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/16/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWAccountAPIClient.h"
#import "AFJSONRequestOperation.h"
#import "OWManagedRecording.h"

static NSString * const kOWAccountAPIClientBaseURLString = @"http://192.168.1.44:8000/api/";


#define kRecordingsKey @"recordings/"
//#define kRecordingKey @"recording/"

#define kEmailKey @"email_address"
#define kPasswordKey @"password"
#define kReasonKey @"reason"
#define kSuccessKey @"success"
#define kUsernameKey @"username"
#define kPubTokenKey @"public_upload_token"
#define kPrivTokenKey @"private_upload_token"
#define kServerIDKey @"server_id"

#define kCreateAccountPath @"create_account"
#define kLoginAccountPath @"login_account"

@implementation OWAccountAPIClient

+ (OWAccountAPIClient *)sharedClient {
    static OWAccountAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[OWAccountAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kOWAccountAPIClientBaseURLString]];
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
    
    return self;
}

- (void) loginWithAccount:(OWAccount*)account success:(void (^)(void)) success failure:(void (^)(NSString *reason))failure {
    [self registerWithAccount:account path:kLoginAccountPath success:success failure:failure];
}

- (void) signupWithAccount:(OWAccount*)account success:(void (^)(void)) success failure:(void (^)(NSString *reason))failure {
    [self registerWithAccount:account path:kCreateAccountPath success:success failure:failure];
}

- (void) registerWithAccount:(OWAccount*)account path:(NSString*)path success:(void (^)(void)) success failure:(void (^)(NSString *reason))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setObject:account.email forKey:kEmailKey];
    [parameters setObject:account.password forKey:kPasswordKey];
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    request.HTTPShouldHandleCookies = YES;
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", [responseObject description]);
        if ([[responseObject objectForKey:kSuccessKey] boolValue]) {
            
            account.username = [responseObject objectForKey:kUsernameKey];
            account.publicUploadToken = [responseObject objectForKey:kPubTokenKey];
            account.privateUploadToken = [responseObject objectForKey:kPrivTokenKey];
            account.accountID = [responseObject objectForKey:kServerIDKey];
            
            success();
        } else {
            failure([responseObject objectForKey:kReasonKey]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure Response: %@", operation.responseString);
        failure([error localizedDescription]);
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void) fetchRecordingsWithSuccessBlock:(void (^)(void))success failure:(void (^)(NSString *))failure {
    [self getPath:kRecordingsKey parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success: %@", [responseObject description]);
        NSArray *recordings = [responseObject objectForKey:@"recordings"];
        for (NSDictionary *recordingDict in recordings) {
            int serverID = [[recordingDict objectForKey:@"id"] intValue];
            int remoteLastEdited = [[recordingDict objectForKey:@"last_edited"] intValue];
            OWManagedRecording *managedRecording = [OWManagedRecording MR_findFirstByAttribute:@"serverID" withValue:@(serverID)];
            if (managedRecording) {
                int localLastEdited = (int)[managedRecording.dateModified timeIntervalSince1970];
                if (remoteLastEdited > localLastEdited) {
                    [self getRecordingWithServerID:serverID success:^{
                        
                    } failure:^(NSString *reason) {
                        
                    }];
                } else {
                    [self postRecordingWithServerID:serverID success:^{
                        
                    } failure:^(NSString *reason) {
                        
                    }];
                }
            } else {
                NSLog(@"Recording found on server that's not on client!");
                [self getRecordingWithServerID:serverID success:^{
                    
                } failure:^(NSString *reason) {
                    
                }];
            }
        }
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure: %@", [error userInfo]);
        failure(@"fart");
    }];
}

- (NSString*)pathForRecordingWithServerID:(NSInteger)serverID {
    return [kRecordingKey stringByAppendingFormat:@"/%d/",serverID];
}

- (void) getRecordingWithServerID:(NSInteger)serverID success:(void (^)(void))success failure:(void (^)(NSString *reason))failure {
    [self getPath:[self pathForRecordingWithServerID:serverID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", [responseObject description] );
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure([error description]);
    }];
}

- (void) postRecordingWithServerID:(NSInteger)serverID success:(void (^)(void))success failure:(void (^)(NSString *reason))failure {
    OWManagedRecording *managedRecording = [OWManagedRecording MR_findFirstByAttribute:@"serverID" withValue:@(serverID)];
    [self postPath:[self pathForRecordingWithServerID:serverID] parameters:managedRecording.metadataDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"post response: %@", [responseObject description]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure([error description]);
    }];
}

                


@end
