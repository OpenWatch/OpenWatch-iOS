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
#import "OWInvestigation.h"
#import "AFImageRequestOperation.h"

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
#define kInvestigationPath @"i/"

#define kTypeKey @"type"
#define kVideoTypeKey @"video"
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
    SDURLCache *urlCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024*10   // 10MB mem cache
                                                         diskCapacity:1024*1024*100 // 100MB disk cache
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

- (void) checkEmailAvailability:(NSString*)email callback:(void (^)(BOOL available))callback {
    
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
    account.user.csrfToken = [responseObject objectForKey:kCSRFTokenKey];
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

- (void) fetchUserRecordingsOnPage:(NSUInteger)page success:(void (^)(NSArray *recordingObjectIDs, NSUInteger totalPages))success failure:(void (^)(NSString *reason))failure {
    [self getPath:[self pathForUserRecordingsOnPage:page] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *recordings = [self objectIDsFromMediaObjectsMetadataArray:[responseObject objectForKey:kObjectsKey]];
        NSDictionary *meta = [responseObject objectForKey:kMetaKey];
        NSUInteger pageCount = [[meta objectForKey:kPageCountKey] unsignedIntegerValue];
        success(recordings, pageCount);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure: %@", [error userInfo]);
        failure(@"fart");
    }];
}

- (NSString*)pathForRecordingWithUUID:(NSString*)UUID {
    return [kRecordingKey stringByAppendingFormat:@"/%@/",UUID];
}

- (void) getRecordingWithUUID:(NSString*)UUID success:(void (^)(NSManagedObjectID *))success failure:(void (^)(NSString *))failure {
    NSString *path = [self pathForRecordingWithUUID:UUID];
    NSLog(@"Fetching %@", path);
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (NSString*) pathForUserRecordingsOnPage:(NSUInteger)page {
    return [NSString stringWithFormat:@"recordings/%d/", page];
}

- (NSString*) pathForFeedType:(OWFeedType)feedType {
    NSString *prefix = nil;
    // TODO rewrite the feed and tag to use GET params
    if (feedType == kOWFeedTypeFeed) {
        prefix = kFeedPath;
    } else if (feedType == kOWFeedTypeTag) {
        prefix = kTagPath;
    } else if (feedType == kOWFeedTypeFrontPage) {
        prefix = kInvestigationPath;
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
        [parameters setObject:feedName forKey:@"feed_name"];
    }
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *mediaObjects = [self objectIDsFromMediaObjectsMetadataArray:[responseObject objectForKey:kObjectsKey]];
        NSDictionary *meta = [responseObject objectForKey:kMetaKey];
        NSUInteger pageCount = [[meta objectForKey:kPageCountKey] unsignedIntegerValue];
        success(mediaObjects, pageCount);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure: %@", [error userInfo]);
        failure(@"couldn't fetch objects");
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

- (void) getInvestigationWithObjectID:(NSManagedObjectID *)objectID success:(void (^)(NSManagedObjectID *recordingObjectID))success failure:(void (^)(NSString *reason))failure {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWInvestigation *story = (OWInvestigation*)[context existingObjectWithID:objectID error:nil];
    NSString *path = [NSString stringWithFormat:@"/api/i/%d/", [story.serverID intValue]];
    NSDictionary *parameters = @{@"html": @"true"};
    [self getPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [story loadMetadataFromDictionary:responseObject];
            success(objectID);
        } else {
            failure(@"not a dict");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(@"it failed");
    }];
}

- (void) getStoryWithObjectID:(NSManagedObjectID *)objectID success:(void (^)(NSManagedObjectID *recordingObjectID))success failure:(void (^)(NSString *reason))failure {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWStory *story = (OWStory*)[context existingObjectWithID:objectID error:nil];
    NSString *path = [NSString stringWithFormat:@"/api/story/%d/", [story.serverID intValue]];

    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *storyMetadata = [responseObject objectForKey:@"story"];
        [story loadMetadataFromDictionary:storyMetadata];
        success(objectID);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(@"it failed");
    }];
}

- (void) fetchMediaObjectsForLocation:(CLLocation*)location page:(NSUInteger)page success:(void (^)(NSArray *mediaObjectIDs, NSUInteger totalPages))success failure:(void (^)(NSString *reason))failure {
    NSString *path = [self pathForFeedType:kOWFeedTypeFeed];
    if (!path) {
        failure(@"Path is nil!");
        return;
    }
    NSDictionary *locationDictionary = @{@"latitude": @(location.coordinate.latitude), @"longitude": @(location.coordinate.longitude)};
    NSDictionary *parameters = @{@"location": locationDictionary};
    [self postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
