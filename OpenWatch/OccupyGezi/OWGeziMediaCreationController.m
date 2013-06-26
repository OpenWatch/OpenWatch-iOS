//
//  OWGeziMediaCreationController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 6/26/13.
//  Copyright (c) 2013 The OpenWatch Corporation, Inc. All rights reserved.
//

#import "OWGeziMediaCreationController.h"

@implementation OWGeziMediaCreationController
@synthesize primaryTag;

- (id) init {
    if (self = [super init]) {
        self.primaryTag = @"occupygezi";
    }
    return self;
}

- (void) setPrimaryTag:(NSString *)newPrimaryTag {
    primaryTag = @"occupygezi";
}

@end
