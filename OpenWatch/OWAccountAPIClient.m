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
#import "OWTag.h"
#import "OWSettingsController.h"
#import "OWUser.h"
#import "OWStory.h"
#import "OWRecordingController.h"
#import "SDURLCache.h"

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
#define kCSRFTokenKey @"csrf_token"

#define kCreateAccountPath @"create_account"
#define kLoginAccountPath @"login_account"
#define kTagPath @"tag/"
#define kFeedPath @"feed/"
#define kTagsPath @"tags/"

#define kTypeKey @"type"
#define kVideoTypeKey @"video"
#define kStoryTypeKey @"story"
#define kUUIDKey @"uuid"

#define kObjectsKey @"objects"

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
    SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024   // 1MB mem cache
                                                         diskCapacity:1024*1024*15 // 15MB disk cache
                                                             diskPath:[SDURLCache defaultCachePath]
                                                   enableForIOS5AndUp:YES];
    urlCache.ignoreMemoryOnlyStoragePolicy = YES;
    [NSURLCache setSharedURLCache:urlCache];
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
            account.user.csrfToken = [responseObject objectForKey:kCSRFTokenKey];
            
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
        NSArray *recordings = [responseObject objectForKey:kObjectsKey];
        
        for (NSDictionary *recordingDict in recordings) {
            NSString *uuid = [recordingDict objectForKey:kUUIDKey];
            int serverID = [[recordingDict objectForKey:kIDKey] intValue];
            NSString *remoteLastEditedString = [recordingDict objectForKey:kLastEditedKey];
            NSDateFormatter *dateFormatter = [OWUtilities utcDateFormatter];
            
            NSDate *remoteLastEditedDate = [dateFormatter dateFromString:remoteLastEditedString];
            OWManagedRecording *managedRecording = [OWManagedRecording MR_findFirstByAttribute:kUUIDKey withValue:uuid];
            managedRecording.serverID = @(serverID);
            NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
            [context MR_saveToPersistentStoreAndWait];
            NSDate *localLastEditedDate = managedRecording.modifiedDate;
            NSString *localLastEditedString = [dateFormatter stringFromDate:managedRecording.modifiedDate];
            if (managedRecording) {
                int localSeconds = (int)[localLastEditedDate timeIntervalSince1970];
                int remoteSeconds = (int)[remoteLastEditedDate timeIntervalSince1970];
                NSLog(@"loc: %@", localLastEditedString);
                NSLog(@"rmt: %@", remoteLastEditedString);
                if (remoteSeconds > localSeconds) {
                    [self getRecordingWithUUID:uuid success:^(NSManagedObjectID *recordingObjectID) {
                        
                    } failure:^(NSString *reason) {
                        
                    }];
                } else if (remoteSeconds < localSeconds) {
                    [self postRecordingWithUUID:uuid success:^{
                        
                    } failure:^(NSString *reason) {
                        
                    }];
                }
            } else {
                NSLog(@"Recording found on server that's not on client!");
                [self getRecordingWithUUID:uuid success:^(NSManagedObjectID *recordingObjectID) {
                    
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

- (void) getRecordingWithUUID:(NSString*)UUID success:(void (^)(NSManagedObjectID *))success failure:(void (^)(NSString *))failure {
    [self getPath:[self pathForRecordingWithUUID:UUID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        NSLog(@"GET Response: %@", operation.responseString);
        NSDictionary *recordingDict = [responseObject objectForKey:kRecordingKey];
        if (recordingDict) {
            NSString *uuid = [recordingDict objectForKey:@"uuid"];
            OWManagedRecording *managedRecording = [OWManagedRecording MR_findFirstByAttribute:@"uuid" withValue:uuid];
            if (managedRecording) {
                [managedRecording loadMetadataFromDictionary:recordingDict];
                [context MR_saveToPersistentStoreAndWait];
                success(managedRecording.objectID);
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
        //failure(@"Failed to POST recording");
    }];
}

- (NSString*) pathForTagFeed:(NSString*)tag page:(NSUInteger)page {
    return [kTagPath stringByAppendingFormat:@"%@/%d/", tag, page];
}

- (NSString*) pathForFeed:(NSString*)feedName page:(NSUInteger)page {
    return [kFeedPath stringByAppendingFormat:@"%@/%d/", feedName, page];
}

- (void) fetchRecordingsForTag:(NSString *)tagName page:(NSUInteger)page success:(void (^)(NSArray *recordings))success failure:(void (^)(NSString *))failure {

    [self getPath:[self pathForTagFeed:tagName page:page] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *recordings = [self objectIDsFromMediaObjectsMetadataArray:[responseObject objectForKey:kObjectsKey]];
        success(recordings);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure: %@", [error userInfo]);
        failure(@"fart");
    }];
}

- (void) fetchRecordingsForFeed:(NSString *)feed page:(NSUInteger)page success:(void (^)(NSArray *))success failure:(void (^)(NSString *))failure {
    [self getPath:[self pathForFeed:feed page:page] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *recordings = [self objectIDsFromMediaObjectsMetadataArray:[responseObject objectForKey:kObjectsKey]];
        success(recordings);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure: %@", [error userInfo]);
        failure(@"fart");
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
        mediaObject = [OWManagedRecording MR_findFirstByAttribute:@"uuid" withValue:uuid];
        if (!mediaObject) {
            mediaObject = [OWManagedRecording MR_createEntity];
        }
    } else if ([type isEqualToString:kStoryTypeKey]) {
        NSString *serverID = [dictionary objectForKey:kIDKey];
        mediaObject = [OWStory MR_findFirstByAttribute:@"serverID" withValue:serverID];
        if (!mediaObject) {
            mediaObject = [OWStory MR_createEntity];
        }
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
            NSNumber *serverID = [tagDictionary objectForKey:@"id"];
            OWTag *tag = [OWTag MR_findFirstByAttribute:@"serverID" withValue:serverID];
            if (!tag) {
                tag = [OWTag MR_createEntity];
                tag.name = [tagDictionary objectForKey:@"name"];
                tag.isFeatured = [tagDictionary objectForKey:@"featured"];
                tag.serverID = serverID;
            }
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
    OWMediaObject *mediaObject = (OWMediaObject*)[context objectWithID:objectID];
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

- (void) getStoryWithObjectID:(NSManagedObjectID *)objectID success:(void (^)(NSManagedObjectID *recordingObjectID))success failure:(void (^)(NSString *reason))failure {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWStory *story = (OWStory*)[context objectWithID:objectID];
    NSString *path = [NSString stringWithFormat:@"/api/story/%d/", [story.serverID intValue]];

    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *storyMetadata = [responseObject objectForKey:@"story"];
        [story loadMetadataFromDictionary:storyMetadata];
        success(objectID);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(@"it failed");
    }];
}


@end
