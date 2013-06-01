//
//  OWUser.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWUser.h"
#import "OWManagedRecording.h"

#define kFirstNameKey @"first_name"
#define kLastNameKey @"last_name"
#define kBioKey @"bio"
#define kThumbnailKey @"thumbnail_url"


@implementation OWUser

- (void) loadMetadataFromDictionary:(NSDictionary*)metadataDictionary {
    [super loadMetadataFromDictionary:metadataDictionary];
    NSString *username = [metadataDictionary objectForKey:kUsernameKey];
    NSString *thumbnail = [metadataDictionary objectForKey:kThumbnailKey];
    self.firstName = [metadataDictionary objectForKey:kFirstNameKey];
    self.lastName = [metadataDictionary objectForKey:kLastNameKey];
    self.bio = [metadataDictionary objectForKey:kBioKey];
    self.username = username;
    self.thumbnailURLString = thumbnail;
}


- (NSMutableDictionary*) metadataDictionary {
    NSMutableDictionary *newMetadataDictionary = [super metadataDictionary];
    if (self.username) {
        [newMetadataDictionary setObject:self.username forKey:kUsernameKey];
    }
    if (self.firstName) {
        [newMetadataDictionary setObject:self.firstName forKey:kFirstNameKey];
    }
    if (self.lastName) {
        [newMetadataDictionary setObject:self.lastName forKey:kLastNameKey];
    }
    if (self.bio) {
        [newMetadataDictionary setObject:self.bio
                                  forKey:kBioKey];
    }
    if (self.thumbnailURLString) {
        [newMetadataDictionary setObject:self.thumbnailURLString forKey:kThumbnailKey];
    }
    return newMetadataDictionary;
}


- (NSURL*) thumbnailURL {
    if (self.thumbnailURLString.length == 0) {
        return nil;
    }
    return [NSURL URLWithString:self.thumbnailURLString];
}

@end
