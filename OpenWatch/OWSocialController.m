//
//  OWSocialController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 7/5/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWSocialController.h"

@implementation OWSocialController

+ (void) profileForTwitterAccount:(ACAccount*)account callbackBlock:(void (^)(NSDictionary *profile, NSError *error))callbackBlock {
    NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
    
    SLRequest *getRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestURL parameters:@{@"screen_name": account.username}];
    getRequest.account = account;
    
    [getRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (callbackBlock) {
                callbackBlock(nil, error);
            }
        }
        NSDictionary *data = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:&error];
        if (error) {
            if (callbackBlock) {
                callbackBlock(nil, error);
            }
        } else {
            if (callbackBlock) {
                callbackBlock(data, nil);
            }
        }
    }];
}

@end
