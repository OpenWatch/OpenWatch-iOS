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
#import "OWLocalRecording.h"
#import "OWUtilities.h"
#import "OWRecordingTag.h"

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
#define kTagPath @"tag/"

@implementation OWAccountAPIClient

+ (NSString*) baseURL {
    return [NSURL URLWithString:[[OWUtilities baseURLString] stringByAppendingFormat:@"api/"]];
}

+ (OWAccountAPIClient *)sharedClient {
    static OWAccountAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[OWAccountAPIClient alloc] initWithBaseURL:[OWAccountAPIClient baseURL]];
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
            NSString *uuid = [recordingDict objectForKey:@"uuid"];
            int serverID = [[recordingDict objectForKey:@"id"] intValue];
            NSString *remoteLastEditedString = [recordingDict objectForKey:@"last_edited"];
            NSDateFormatter *dateFormatter = [OWUtilities dateFormatter];
            
            NSDate *remoteLastEditedDate = [dateFormatter dateFromString:remoteLastEditedString];
            OWManagedRecording *managedRecording = [OWManagedRecording MR_findFirstByAttribute:@"uuid" withValue:uuid];
            managedRecording.serverID = @(serverID);
            NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
            [context MR_saveNestedContexts];
            NSDate *localLastEditedDate = managedRecording.dateModified;
            NSString *localLastEditedString = [dateFormatter stringFromDate:managedRecording.dateModified];
            if (managedRecording) {
                int localSeconds = (int)[localLastEditedDate timeIntervalSince1970];
                int remoteSeconds = (int)[remoteLastEditedDate timeIntervalSince1970];
                NSLog(@"loc: %@", localLastEditedString);
                NSLog(@"rmt: %@", remoteLastEditedString);
                if (remoteSeconds > localSeconds) {
                    [self getRecordingWithUUID:uuid success:^{
                        
                    } failure:^(NSString *reason) {
                        
                    }];
                } else if (remoteSeconds < localSeconds) {
                    [self postRecordingWithUUID:uuid success:^{
                        
                    } failure:^(NSString *reason) {
                        
                    }];
                }
            } else {
                NSLog(@"Recording found on server that's not on client!");
                [self getRecordingWithUUID:uuid success:^{
                    
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

- (NSString*)pathForRecordingWithUUID:(NSString*)UUID {
    return [kRecordingKey stringByAppendingFormat:@"/%@/",UUID];
}

- (void) getRecordingWithUUID:(NSString*)UUID success:(void (^)(void))success failure:(void (^)(NSString *reason))failure {
    [self getPath:[self pathForRecordingWithUUID:UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        NSLog(@"GET Response: %@", [responseObject description] );
        NSDictionary *recordingDict = [responseObject objectForKey:kRecordingKey];
        if (recordingDict) {
            NSString *uuid = [recordingDict objectForKey:@"uuid"];
            OWManagedRecording *managedRecording = [OWManagedRecording MR_findFirstByAttribute:@"uuid" withValue:uuid];
            if (managedRecording) {
                [managedRecording loadMetadataFromDictionary:recordingDict];
                [context MR_saveNestedContexts];
                success();
            } else {
                failure(@"No recording found");
            }
        } else {
            failure([NSString stringWithFormat:@"Bad response from server: %@", [responseObject description]]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure([error description]);
    }];
}

- (void) postRecordingWithUUID:(NSString*)UUID success:(void (^)(void))success failure:(void (^)(NSString *reason))failure {
    OWManagedRecording *managedRecording = [OWManagedRecording MR_findFirstByAttribute:@"uuid" withValue:UUID];
    if (!managedRecording) {
        NSLog(@"Recording %@ not found!", UUID);
        return;
    }
    [self postPath:[self pathForRecordingWithUUID:UUID] parameters:managedRecording.metadataDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST response: %@", [responseObject description]);
        //NSLog(@"POST body: %@", operation.request.HTTPBody);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail: %@", operation.responseString);
        failure([error description]);
    }];
}

- (NSString*) pathForTagFeed:(NSString*)tag {
    return [kTagPath stringByAppendingString:tag];
}

- (void) fetchRecordingsForTag:(NSString *)tagName success:(void (^)(NSArray *recordings))success failure:(void (^)(NSString *))failure {

    [self getPath:[self pathForTagFeed:tagName] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];

        OWRecordingTag *tag = [OWRecordingTag MR_findFirstByAttribute:@"name" withValue:tagName];
        if (!tag) {
            tag = [OWRecordingTag MR_createEntity];
            tag.name = [tagName lowercaseString];
        }
        
        NSLog(@"success: %@", [responseObject description]);
        NSArray *recordings = [responseObject objectForKey:@"recordings"];
        NSMutableArray *recordingsToReturn = [NSMutableArray arrayWithCapacity:[recordings count]];
        for (NSDictionary *recordingDict in recordings) {
            OWManagedRecording *managedRecording = [self managedRecordingForShortMetadataDictionary:recordingDict];
            if (tag) {
                [managedRecording addTagsObject:tag];
            }
            if (managedRecording) {
                [recordingsToReturn addObject:managedRecording.objectID];
            }
        }
        [context MR_saveNestedContexts];
        success(recordingsToReturn);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure: %@", [error userInfo]);
        failure(@"fart");
    }];
}

- (OWManagedRecording*) managedRecordingForShortMetadataDictionary:(NSDictionary*)recordingDict {
    NSString *uuid = [recordingDict objectForKey:@"uuid"];
    OWManagedRecording *managedRecording = [OWManagedRecording MR_findFirstByAttribute:@"uuid" withValue:uuid];
    if (!managedRecording) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        NSError *error = nil;
        managedRecording = [OWManagedRecording MR_createEntity];
        [context obtainPermanentIDsForObjects:@[managedRecording] error:&error];
        if (error) {
            NSLog(@"Error getting permanent ID: %@", [error userInfo]);
        }
    }
    [managedRecording loadMetadataFromDictionary:recordingDict];
    return managedRecording;
}


@end
