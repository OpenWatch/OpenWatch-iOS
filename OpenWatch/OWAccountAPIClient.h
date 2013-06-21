//
//  OWAccountAPIClient.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/16/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "OWFeedViewController.h"
#import "OWAccount.h"
#import <CoreLocation/CoreLocation.h>

#define kHitTypeClick @"click"
#define kHitTypeView @"view"

#define kOWAccountAPIClientDefaultRetryCount 5

@interface OWAccountAPIClient : AFHTTPClient

+ (OWAccountAPIClient *)sharedClient;
+ (NSURL*) baseURL;

- (void) checkEmailAvailability:(NSString*)email callback:(void (^)(BOOL available))callback;
- (void) quickSignupWithAccount:(OWAccount*)account callback:(void (^)(BOOL success))callback;

- (void) loginWithAccount:(OWAccount*)account success:(void (^)(void)) success failure:(void (^)(NSString *reason))failure;
- (void) signupWithAccount:(OWAccount*)account success:(void (^)(void)) success failure:(void (^)(NSString *reason))failure;

- (void) getSubscribedTagsWithSuccessBlock:(void (^)(NSSet *tags))successBlock failureBlock:(void (^)(NSString *reason))failureBlock;

- (void) updateUserPushToken:(NSData*)token;
- (void) updateUserLocation:(CLLocation*)location;
- (void) updateUserSecretAgentStatus:(BOOL)secretAgentEnabled;
- (void) updateUserPhoto:(UIImage*)photo;
- (void) updateUserProfile;

- (void) postObjectWithUUID:(NSString*)UUID objectClass:(Class)objectClass success:(void (^)(void))success failure:(void (^)(NSString *reason))failure retryCount:(NSUInteger)retryCount;
- (void) getObjectWithUUID:(NSString*)UUID objectClass:(Class)objectClass success:(void (^)(NSManagedObjectID *objectID))success failure:(void (^)(NSString *reason))failure retryCount:(NSUInteger)retryCount;
- (void) getObjectWithObjectID:(NSManagedObjectID *)objectID success:(void (^)(NSManagedObjectID *objectID))success failure:(void (^)(NSString *reason))failure  retryCount:(NSUInteger)retryCount;

- (void) fetchMediaObjectsForFeedType:(OWFeedType)feedType feedName:(NSString*)feedName page:(NSUInteger)page success:(void (^)(NSArray *mediaObjectIDs, NSUInteger totalPages))success failure:(void (^)(NSString *reason))failure;
- (void) fetchMediaObjectsForLocation:(CLLocation*)location page:(NSUInteger)page success:(void (^)(NSArray *mediaObjectIDs, NSUInteger totalPages))success failure:(void (^)(NSString *reason))failure; 



- (void) hitMediaObject:(NSManagedObjectID*)objectID hitType:(NSString*)hitType;


@end
