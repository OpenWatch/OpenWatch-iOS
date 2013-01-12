//
//  OWAccountAPIClient.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/16/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "OWAccount.h"

#define kHitTypeClick @"click"
#define kHitTypeView @"view"

@interface OWAccountAPIClient : AFHTTPClient

+ (OWAccountAPIClient *)sharedClient;
+ (NSURL*) baseURL;

- (void) loginWithAccount:(OWAccount*)account success:(void (^)(void)) success failure:(void (^)(NSString *reason))failure;
- (void) signupWithAccount:(OWAccount*)account success:(void (^)(void)) success failure:(void (^)(NSString *reason))failure;
- (void) updateSubscribedTags;

- (void) fetchRecordingsWithSuccessBlock:(void (^)(void)) success failure:(void (^)(NSString *reason))failure;
- (void) postRecordingWithUUID:(NSString*)UUID success:(void (^)(void))success failure:(void (^)(NSString *reason))failure;
- (void) getRecordingWithUUID:(NSString*)UUID success:(void (^)(NSManagedObjectID *recordingObjectID))success failure:(void (^)(NSString *reason))failure;

- (void) fetchRecordingsForTag:(NSString*)tag page:(NSUInteger)page success:(void (^)(NSArray *recordingObjectIDs))success failure:(void (^)(NSString *reason))failure;
- (void) fetchRecordingsForFeed:(NSString*)feed page:(NSUInteger)page success:(void (^)(NSArray *recordingObjectIDs))success failure:(void (^)(NSString *reason))failure;

- (void) hitRecording:(NSManagedObjectID*)objectID hitType:(NSString*)hitType;


@end
