//
//  OWUser.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWUser.h"
#import "OWManagedRecording.h"


@implementation OWUser

@dynamic username;
@dynamic serverID;
@dynamic recordings;
@dynamic tags;
@dynamic csrfToken;
@dynamic thumbnailURLString;

- (NSURL*) thumbnailURL {
    if (self.thumbnailURLString.length == 0) {
        return nil;
    }
    return [NSURL URLWithString:self.thumbnailURLString];
}

@end
