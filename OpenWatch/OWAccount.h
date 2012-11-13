//
//  OWAccount.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWAccount : NSObject

@property (nonatomic, strong) NSString *accountName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *publicUploadToken;
@property (nonatomic, strong) NSString *privateUploadToken;
@property (nonatomic, strong) NSString *password;

- (void) clearAccountData;

@end
