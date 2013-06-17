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
#import "OWConstants.h"
#import "OWLocalRecording.h"
#import "OWUtilities.h"
#import "OWTag.h"
#import "OWSettingsController.h"
#import "OWUser.h"
#import "OWStory.h"
#import "OWRecordingController.h"
#import "OWInvestigation.h"
#import "OWLocalMediaController.h"
#import "AFImageRequestOperation.h"
#import "OWPhoto.h"
#import "OWLocalRecording.h"
#import "OWAudio.h"
#import "OWCaptureAPIClient.h"
#import "JSONKit.h"
#import "NSData+Hex.h"
#import "OWBadgedDashboardItem.h"
#import "OWMission.h"

#define kRecordingsKey @"recordings/"

#define kEmailKey @"email_address"
#define kPasswordKey @"password"
#define kReasonKey @"reason"
#define kSuccessKey @"success"
#define kUsernameKey @"username"
#define kPubTokenKey @"public_upload_token"
#define kPrivTokenKey @"private_upload_token"
#define kServerIDKey @"server_id"
#define kCSRFTokenKey @"csrf_token"

#define kCreateAccountPath @"create_account"
#define kLoginAccountPath @"login_account"
#define kTagPath @"tag/"
#define kFeedPath @"feed/"
#define kTagsPath @"tags/"
#define kInvestigationPath @"i/"

#define kTypeKey @"type"
#define kVideoTypeKey @"video"
#define kPhotoTypeKey @"photo"
#define kAudioTypeKey @"audio"
#define kInvestigationTypeKey @"investigation"
#define kStoryTypeKey @"story"
#define kUUIDKey @"uuid"

#define kObjectsKey @"objects"
#define kMetaKey @"meta"
#define kPageCountKey @"page_count"

@implementation OWAccountAPIClient

+ (NSString*) baseURL {
    return [NSURL URLWithString:[[OWUtilities apiBaseURLString] stringByAppendingFormat:@"api/"]];
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
    NSString* string = @"binary/octet-stream";
    [AFImageRequestOperation addAcceptableContentTypes: [NSSet setWithObject:string]];
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    self.parameterEncoding = AFJSONParameterEncoding;
    
    [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [OWLocalMediaController scanDirectoryForUnsubmittedData];
            });
        }
    }];
    
    return self;
}

- (NSMutableURLRequest*) requestWithMethod:(NSString*)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    NSDictionary *newParameters = nil;
    if ([method isEqualToString:@"POST"]) { // Make sure to REALLY send that csrf token
        NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        
        NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:[OWUtilities apiBaseURLString]]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"csrftoken"];
        NSArray *filteredCookies = [cookies filteredArrayUsingPredicate:predicate];
        
        if (filteredCookies.count > 0) {
            NSHTTPCookie *csrfCookie = [filteredCookies objectAtIndex:0];
            [mutableParameters setObject:csrfCookie.value forKey:@"csrf_token"];
            [mutableParameters setObject:csrfCookie.value forKey:@"csrfmiddlewaretoken"];
            
            [self setDefaultHeader:@"X-CSRFToken" value:csrfCookie.value];
        }
        newParameters = mutableParameters;
    } else {
        newParameters = parameters;
    }

    
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:newParameters];
    request.HTTPShouldHandleCookies = YES;
    
    return request;
}


- (void) checkEmailAvailability:(NSString*)email callback:(void (^)(BOOL available))callback {
    if (!email) {
        NSLog(@"Email is nil!");
        return;
    }
    [self getPath:@"email_available" parameters:@{@"email": email} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL available = [[responseObject objectForKey:@"available"] boolValue];
        callback(available);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error checking email availability: %@", error.userInfo);
        callback(NO);
    }];
}

- (void) quickSignupWithAccount:(OWAccount*)account callback:(void (^)(BOOL success))callback {
    [self postPath:@"quick_signup" parameters:@{@"email": account.email} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL success = [[responseObject objectForKey:@"success"] boolValue];
        if (success) {
            [self processLoginDictionary:responseObject account:account];
        }
        NSLog(@"quickSignup response: %@", responseObject);
        callback(success);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error signing up for account: %@", error.userInfo);
        callback(NO);
    }];
}

- (void) loginWithAccount:(OWAccount*)account success:(void (^)(void)) success failure:(void (^)(NSString *reason))failure {
    [self registerWithAccount:account path:kLoginAccountPath success:success failure:failure];
}

- (void) signupWithAccount:(OWAccount*)account success:(void (^)(void)) success failure:(void (^)(NSString *reason))failure {
    [self registerWithAccount:account path:kCreateAccountPath success:success failure:failure];
}

- (void) processLoginDictionary:(NSDictionary*)responseObject account:(OWAccount*)account {
    account.username = [responseObject objectForKey:kUsernameKey];
    account.publicUploadToken = [responseObject objectForKey:kPubTokenKey];
    account.privateUploadToken = [responseObject objectForKey:kPrivTokenKey];
    account.accountID = [responseObject objectForKey:kServerIDKey];
}

- (void) updateUserPushToken:(NSData*)token {
    NSString *tokenString = [token hexadecimalString];
    [self updateAccountWithDetails:@{@"apple_push_token": tokenString}];
}

- (void) updateUserLocation:(CLLocation*)location {
    if (!location) {
        NSLog(@"Location is nil!");
        return;
    }
    [self updateAccountWithDetails:@{@"latitude": @(location.coordinate.latitude), @"longitude": @(location.coordinate.longitude)}];
}

- (void) updateUserSecretAgentStatus:(BOOL)secretAgentEnabled {
    [self updateAccountWithDetails:@{@"agent_applicant": @(secretAgentEnabled)}];
}

- (void) updateUserPhoto:(UIImage*)photo {
    if (!photo) {
        return;
    }
    OWAccount *account = [OWSettingsController sharedInstance].account;
    if (!account.isLoggedIn) {
        NSLog(@"Account not logged in!");
        return;
    }
    
    
    NSString *path = [NSString stringWithFormat:@"/api/u/%@/", account.accountID];
    
    NSURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:path parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
        if (photo) {
            NSData *jpegData = UIImageJPEGRepresentation(photo, 0.85);
            [formData appendPartWithFileData:jpegData name:@"file_data" fileName:@"profile.jpeg" mimeType:@"image/jpeg"];
        }
    }];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Updated account details: %@", operation.responseString);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            BOOL success = [[responseObject objectForKey:@"success"] boolValue];
            NSString *reason = [responseObject objectForKey:@"reason"];
            NSNumber *code = [responseObject objectForKey:@"code"];
            if (success) {
                NSLog(@"success!");
            } else {
                NSLog(@"Failed to update account photo: %@ %@", code, reason);
                if (code.integerValue == 428) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAccountPermissionsError object:nil];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to update account photo: %@", error.userInfo);
        
    }];
    [operation start];
}

- (void) updateUserProfile {
    OWAccount *account = [OWSettingsController sharedInstance].account;
    OWUser *user = account.user;
    
    NSDictionary *params = user.metadataDictionary;
    
    [self updateAccountWithDetails:params];
}

- (void) updateAccountWithDetails:(NSDictionary*)details {
    OWAccount *account = [OWSettingsController sharedInstance].account;
    if (!account.isLoggedIn) {
        NSLog(@"Account not logged in!");
        return;
    }
    
    NSLog(@"Updating account details... %@", details.description);
    
    NSString *path = [NSString stringWithFormat:@"/api/u/%@/", account.accountID];
    
    [self postPath:path parameters:details success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Updated account details: %@", operation.responseString);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            BOOL success = [[responseObject objectForKey:@"success"] boolValue];
            NSString *reason = [responseObject objectForKey:@"reason"];
            NSNumber *code = [responseObject objectForKey:@"code"];
            if (success) {
                NSLog(@"success!");
            } else {
                NSLog(@"Failed to update account details: %@ %@", code, reason);
                if (code.integerValue == 428) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAccountPermissionsError object:nil];
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to update account details: %@", error.userInfo);
    }];
}

- (void) registerWithAccount:(OWAccount*)account path:(NSString*)path success:(void (^)(void)) success failure:(void (^)(NSString *reason))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setObject:account.email forKey:kEmailKey];
    [parameters setObject:account.password forKey:kPasswordKey];
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", [responseObject description]);
        if ([[responseObject objectForKey:kSuccessKey] boolValue]) {
            
            [self processLoginDictionary:responseObject account:account];
            
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

- (NSString*) pathForClass:(Class)class {
    NSString *prefix = nil;
    if ([class isEqual:[OWPhoto class]]) {
        prefix = @"p/";
    } else if ([class isEqual:[OWManagedRecording class]] || [class isEqual:[OWLocalRecording class]]) {
        prefix = @"v/";
    } else if ([class isEqual:[OWAudio class]]) {
        prefix = @"a/";
    } else {
        return nil;
    }
    return prefix;
}

- (NSString*) pathForClass:(Class)class uuid:(NSString*)uuid {
    NSString *prefix = [self pathForClass:class];
    return [NSString stringWithFormat:@"%@%@/", prefix, uuid];
}

- (void) getObjectWithUUID:(NSString*)UUID objectClass:(Class)objectClass success:(void (^)(NSManagedObjectID *objectID))success failure:(void (^)(NSString *reason))failure retryCount:(NSUInteger)retryCount {

    
    NSString *path = [self pathForClass:objectClass uuid:UUID];
    NSLog(@"[Django] GET (%d) %@", retryCount, path);

    if (retryCount <= 0) {
        NSLog(@"Total failure trying to GET object: %@", path);
        if (failure) {
            failure(@"Total failure trying to GET object");
        }
        return;
    }
    
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        NSLog(@"GET Response: %@", operation.responseString);
        BOOL successValue = NO;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            OWLocalMediaObject *mediaObject = [objectClass localMediaObjectWithUUID:UUID];
            if (mediaObject) {
                [mediaObject loadMetadataFromDictionary:responseObject];
                [context MR_saveToPersistentStoreAndWait];
                success(mediaObject.objectID);
                successValue = YES;
            }
        }
        if (!successValue) {
            [self getObjectWithUUID:UUID objectClass:objectClass success:success failure:failure retryCount:retryCount - 1];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to GET: %@", error.userInfo);
        [self getObjectWithUUID:UUID objectClass:objectClass success:success failure:failure retryCount:retryCount - 1];
    }];
}

- (void) postObjectWithUUID:(NSString*)UUID objectClass:(Class)objectClass success:(void (^)(void))success failure:(void (^)(NSString *reason))failure retryCount:(NSUInteger)retryCount {
    
    
    OWLocalMediaObject *mediaObject = [objectClass localMediaObjectWithUUID:UUID];
    NSManagedObjectID *mediaObjectID = mediaObject.objectID;
    if (!mediaObject) {
        NSLog(@"Object %@ (%@) not found!", UUID, NSStringFromClass(objectClass));
        return;
    }
    
    NSDictionary *parameters = mediaObject.metadataDictionary;
    
    NSLog(@"[Django] POSTing object with parameters (%d): %@", retryCount, parameters);
    
    if (retryCount <= 0) {
        NSLog(@"Total failure trying to POST object: %@", mediaObject);
        if (failure) {
            failure(@"Total failure trying to POST object");
        }
        return;
    }

    
    void (^failureBlock)(AFHTTPRequestOperation*, NSError*) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to POST recording: %@ %@", operation.responseString, error.userInfo);
        [self postObjectWithUUID:UUID objectClass:objectClass success:success failure:failure retryCount:retryCount - 1];
    };

    void (^successBlock)(AFHTTPRequestOperation*, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        OWLocalMediaObject *localMediaObject = (OWLocalMediaObject*)[context existingObjectWithID:mediaObjectID error:nil];
        
        NSLog(@"POST response: %@", [responseObject description]);
        if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject objectForKey:@"success"] boolValue]) {
            NSDictionary *object = [responseObject objectForKey:@"object"];
            [localMediaObject loadMetadataFromDictionary:object];
        }
        if (localMediaObject.uploadedValue == NO && ([localMediaObject isKindOfClass:[OWPhoto class]] || [localMediaObject isKindOfClass:[OWAudio class]])) {
            NSString *postPath = [self pathForClass:objectClass uuid:UUID];
            NSURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:postPath parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
                NSError *error = nil;
                [formData appendPartWithFileURL:localMediaObject.localMediaURL name:@"file_data" error:&error];
                
                if (error) {
                    NSLog(@"Error appending part file URL %@: %@%@", localMediaObject.localMediaURL, [error localizedDescription], [error userInfo]);
                }
                
            }];
            AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
            localMediaObject.uploaded = @(YES);
            [context MR_saveToPersistentStoreAndWait];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
                OWLocalMediaObject *successMediaObject = (OWLocalMediaObject*)[localContext existingObjectWithID:mediaObjectID error:nil];
                BOOL successValue = NO;
                NSLog(@"media POST response: %@", operation.responseString);
                if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject objectForKey:@"success"] boolValue]) {
                    successMediaObject.uploaded = @(YES);
                    successValue = YES;
                    [localContext MR_saveToPersistentStoreAndWait];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kOWCaptureAPIClientBandwidthNotification object:nil];
                    if (success) {
                        success();
                    }
                }
                if (!successValue) {
                    NSLog(@"Success is not true!");
                    [self postObjectWithUUID:UUID objectClass:objectClass success:success failure:failure retryCount:retryCount - 1];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Failed to upload photo: %@", error.userInfo);
                [self postObjectWithUUID:UUID objectClass:objectClass success:success failure:failure retryCount:retryCount - 1];
            }];
            [self enqueueHTTPRequestOperation:operation];
        }
    };
    
    NSString *path = nil;
    if (mediaObject.serverID.intValue == 0) {
        [self getObjectWithUUID:mediaObject.uuid objectClass:[mediaObject class] success:^(NSManagedObjectID *objectID) {
            [self postPath:[self pathForClass:objectClass uuid:UUID] parameters:parameters success:successBlock failure:failureBlock];
        } failure:^(NSString *reason) {
            [self postPath:[self pathForClass:objectClass] parameters:parameters success:successBlock failure:failureBlock];
        } retryCount:kOWAccountAPIClientDefaultRetryCount];
    } else {
        path = [self pathForClass:objectClass uuid:UUID];
        [self postPath:path parameters:parameters success:successBlock failure:failureBlock];
    }
}

- (NSString*) pathForUserRecordingsOnPage:(NSUInteger)page {
    return [NSString stringWithFormat:@"recordings/%d/", page];
}

- (NSString*) pathForFeedType:(OWFeedType)feedType {
    NSString *prefix = nil;
    // TODO rewrite the feed and tag to use GET params
    if (feedType == kOWFeedTypeFeed) {
        prefix = kFeedPath;
    } else if (feedType == kOWFeedTypeFrontPage) {
        prefix = kInvestigationPath;
    } else if (feedType == kOWFeedTypeMissions) {
        prefix = @"mission/";
    }
    return prefix;
}


- (void) fetchMediaObjectsForFeedType:(OWFeedType)feedType feedName:(NSString*)feedName page:(NSUInteger)page success:(void (^)(NSArray *mediaObjectIDs, NSUInteger totalPages))success failure:(void (^)(NSString *reason))failure {
    NSString *path = [self pathForFeedType:feedType];
    if (!path) {
        failure(@"Path is nil!");
        return;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@(page) forKey:@"page"];
    if (feedName) {
        [parameters setObject:feedName forKey:@"type"];
    }
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *mediaObjects = [self objectIDsFromMediaObjectsMetadataArray:[responseObject objectForKey:kObjectsKey]];
        NSDictionary *meta = [responseObject objectForKey:kMetaKey];
        NSUInteger pageCount = [[meta objectForKey:kPageCountKey] unsignedIntegerValue];
        NSUInteger objectCount = [[meta objectForKey:@"object_count"] unsignedIntegerValue];
        
        if (feedType == kOWFeedTypeMissions && objectCount > 0) {
            [OWMission updateUnreadCount];
        }
        if (success) {
            success(mediaObjects, pageCount);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure: %@", [error userInfo]);
        if (failure) {
            failure(@"couldn't fetch objects");
        }
    }];

}

- (NSArray*) objectIDsFromMediaObjectsMetadataArray:(NSArray*)array {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSMutableArray *objectIDsToReturn = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSDictionary *recordingDict in array) {
        OWMediaObject *mediaObject = [self mediaObjectForShortMetadataDictionary:recordingDict];
        if (mediaObject) {
            [objectIDsToReturn addObject:mediaObject.objectID];
        }
    }
    [context MR_saveToPersistentStoreAndWait];
    return objectIDsToReturn;
}

- (OWMediaObject*) mediaObjectForShortMetadataDictionary:(NSDictionary*)dictionary {
    OWMediaObject *mediaObject = nil;
    NSString *type = [dictionary objectForKey:kTypeKey];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    if ([type isEqualToString:kVideoTypeKey]) {
        NSString *uuid = [dictionary objectForKey:kUUIDKey];
        if (uuid.length == 0) {
            NSLog(@"no uuid!");
        }
        mediaObject = [OWManagedRecording MR_findFirstByAttribute:@"uuid" withValue:uuid];
        if (!mediaObject) {
            mediaObject = [OWManagedRecording MR_createEntity];
        }
    } else if ([type isEqualToString:kPhotoTypeKey]) {
        NSString *uuid = [dictionary objectForKey:kUUIDKey];
        NSString *serverID = [dictionary objectForKey:kIDKey];
        if (uuid.length != 0) {
            mediaObject = [OWPhoto MR_findFirstByAttribute:@"uuid" withValue:uuid];
        } else {
            mediaObject = [OWPhoto MR_findFirstByAttribute:@"serverID" withValue:serverID];
        }
        if (!mediaObject) {
            mediaObject = [OWPhoto MR_createEntity];
        }
    } else if ([type isEqualToString:kAudioTypeKey]) {
        NSString *uuid = [dictionary objectForKey:kUUIDKey];
        NSString *serverID = [dictionary objectForKey:kIDKey];
        if (uuid.length != 0) {
            mediaObject = [OWAudio MR_findFirstByAttribute:@"uuid" withValue:uuid];
        } else {
            mediaObject = [OWAudio MR_findFirstByAttribute:@"serverID" withValue:serverID];
        }
        if (!mediaObject) {
            mediaObject = [OWAudio MR_createEntity];
        }
    } else if ([type isEqualToString:kStoryTypeKey]) {
        NSString *serverID = [dictionary objectForKey:kIDKey];
        mediaObject = [OWStory MR_findFirstByAttribute:@"serverID" withValue:serverID];
        if (!mediaObject) {
            mediaObject = [OWStory MR_createEntity];
        }
    } else if ([type isEqualToString:kInvestigationTypeKey]) {
        NSString *serverID = [dictionary objectForKey:kIDKey];
        mediaObject = [OWInvestigation MR_findFirstByAttribute:@"serverID" withValue:serverID];
        if (!mediaObject) {
            mediaObject = [OWInvestigation MR_createEntity];
        }
    } else if ([type isEqualToString:@"mission"]) {
        NSString *serverID = [dictionary objectForKey:kIDKey];
        mediaObject = [OWMission MR_findFirstByAttribute:@"serverID" withValue:serverID];
        if (!mediaObject) {
            mediaObject = [OWMission MR_createEntity];
            OWMission *mission = (OWMission*)mediaObject;
            mission.viewed = @(NO);
        }
    } else {
        return nil;
    }
    NSError *error = nil;
    [context obtainPermanentIDsForObjects:@[mediaObject] error:&error];
    if (error) {
        NSLog(@"Error getting permanent ID: %@", [error userInfo]);
    }
    [mediaObject loadMetadataFromDictionary:dictionary];
    return mediaObject;
}

- (void) postSubscribedTags {
    OWAccount *account = [OWSettingsController sharedInstance].account;
    if (!account.isLoggedIn) {
        return;
    }
    NSSet *tags = account.user.tags;
    NSMutableArray *tagsArray = [NSMutableArray arrayWithCapacity:tags.count];
    for (OWTag *tag in tags) {
        NSDictionary *tagDictionary = @{@"name" : [tag.name lowercaseString]};
        [tagsArray addObject:tagDictionary];
    }
    NSDictionary *parameters = @{kTagsKey : tagsArray};
    
    [self postPath:kTagsPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Tags updated on server");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to post tags: %@", operation.responseString);

    }];
}


- (void) getSubscribedTags {
    OWAccount *account = [OWSettingsController sharedInstance].account;
    if (!account.isLoggedIn) {
        return;
    }
    [self getPath:kTagsPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        OWUser *user = account.user;
        NSArray *rawTags = [responseObject objectForKey:@"tags"];
        NSMutableSet *tags = [NSMutableSet setWithCapacity:[rawTags count]];
        for (NSDictionary *tagDictionary in rawTags) {
            OWTag *tag = [OWTag tagWithDictionary:tagDictionary];
            [tags addObject:tag];
        }
        user.tags = tags;
        [context MR_saveToPersistentStoreAndWait];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to load tags: %@", operation.responseString);
    }];

}

- (void) hitMediaObject:(NSManagedObjectID*)objectID hitType:(NSString*)hitType {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context existingObjectWithID:objectID error:nil];
    if (!mediaObject) {
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:3];
    [parameters setObject:mediaObject.serverID forKey:@"serverID"];
    [parameters setObject:hitType forKey:@"hit_type"];
    [parameters setObject:mediaObject.type forKey:@"media_type"];
    
    [self postPath:@"increase_hitcount/" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"hit response: %@", operation.responseString);
        NSLog(@"request: %@", operation.request.allHTTPHeaderFields);
        NSString *httpBody = [NSString stringWithUTF8String:operation.request.HTTPBody.bytes];
        NSLog(@"request body: %@", httpBody);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"hit failure: %@", operation.responseString);
        NSLog(@"request: %@", operation.request.allHTTPHeaderFields);
        NSString *httpBody = [NSString stringWithUTF8String:operation.request.HTTPBody.bytes];
        NSLog(@"request body: %@", httpBody);
    }];
    
    
}

- (void) getObjectWithObjectID:(NSManagedObjectID *)objectID success:(void (^)(NSManagedObjectID *objectID))success failure:(void (^)(NSString *reason))failure retryCount:(NSUInteger)retryCount {
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context existingObjectWithID:objectID error:nil];
    NSString *path = [mediaObject fullAPIPath];
    
    NSLog(@"[Django] GET (%d): %@", retryCount, path);
    
    if (retryCount <= 0) {
        NSLog(@"Total failure trying to GET object: %@ %@", mediaObject, path);
        if (failure) {
            failure(@"Total failure trying to GET object");
        }
        return;
    }
    
    NSDictionary *parameters = [self parametersForMediaObject:mediaObject];
    
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL successValue = NO;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [mediaObject loadMetadataFromDictionary:responseObject];
            successValue = YES;
            if (success) {
                success(objectID);
            }
        }
        if (!successValue) {
            NSLog(@"Response for %@ not a dictionary!", path);
            [self getObjectWithObjectID:objectID success:success failure:failure retryCount:retryCount - 1];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to GET object: %@", error.userInfo);
        [self getObjectWithObjectID:objectID success:success failure:failure retryCount:retryCount - 1];
    }];
}

- (NSDictionary*) parametersForMediaObject:(OWMediaObject*)mediaObject {
    if ([mediaObject isKindOfClass:[OWInvestigation class]]) {
        NSDictionary *parameters = @{@"html": @"true"};
        return parameters;
    }
    return nil;
}

- (void) fetchMediaObjectsForLocation:(CLLocation*)location page:(NSUInteger)page success:(void (^)(NSArray *mediaObjectIDs, NSUInteger totalPages))success failure:(void (^)(NSString *reason))failure {
    NSString *path = [self pathForFeedType:kOWFeedTypeFeed];
    if (!path) {
        failure(@"Path is nil!");
        return;
    }
    NSDictionary *locationDictionary = @{@"latitude": @(location.coordinate.latitude), @"longitude": @(location.coordinate.longitude), @"page": @(page), @"type": @"local"};
    [self getPath:path parameters:locationDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *recordings = [self objectIDsFromMediaObjectsMetadataArray:[responseObject objectForKey:kObjectsKey]];
        NSDictionary *meta = [responseObject objectForKey:kMetaKey];
        NSUInteger pageCount = [[meta objectForKey:kPageCountKey] unsignedIntegerValue];
        success(recordings, pageCount);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure: %@", [error userInfo]);
        failure(@"couldn't fetch objects");
    }];
}

@end
