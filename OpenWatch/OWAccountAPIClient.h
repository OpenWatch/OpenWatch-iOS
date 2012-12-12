//
//  OWAccountAPIClient.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/16/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "OWAccount.h"

@interface OWAccountAPIClient : AFHTTPClient

+ (OWAccountAPIClient *)sharedClient;
+ (NSURL*) baseURL;

- (void) loginWithAccount:(OWAccount*)account success:(void (^)(void)) success failure:(void (^)(NSString *reason))failure;
- (void) signupWithAccount:(OWAccount*)account success:(void (^)(void)) success failure:(void (^)(NSString *reason))failure;
- (void) fetchRecordingsWithSuccessBlock:(void (^)(void)) success failure:(void (^)(NSString *reason))failure;
- (void) fetchRecordingsForTag:(NSString*)tag success:(void (^)(NSArray *recordingObjectIDs))success failure:(void (^)(NSString *reason))failure;

@end
