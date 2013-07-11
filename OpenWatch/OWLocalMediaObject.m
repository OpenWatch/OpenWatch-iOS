//
//  OWLocalMediaObject.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/7/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWLocalMediaObject.h"
#import "OWLocalRecording.h"
#import "OWPhoto.h"
#import "OWSettingsController.h"
#import "OWLocationController.h"

#define kPublicKey @"public"

@implementation OWLocalMediaObject

+ (CLLocation*) locationWithLatitude:(double)latitude longitude:(double)longitude {
    if (latitude == 0.0f && longitude == 0.0f) {
        return nil;
    }
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

- (CLLocation*) endLocation {
    return [OWLocalMediaObject locationWithLatitude:[self.endLatitude doubleValue] longitude:[self.endLongitude doubleValue]];
}

- (void) loadMetadataFromDictionary:(NSDictionary*)metadataDictionary {
    [super loadMetadataFromDictionary:metadataDictionary];
    NSString *newUUID = [metadataDictionary objectForKey:kUUIDKey];
    if (newUUID) {
        self.uuid = newUUID;
    } else {
        NSLog(@"uuid not found!");
    }
    double endLatitude = [[metadataDictionary objectForKey:kLatitudeEndKey] doubleValue];
    if (endLatitude != 0.0f) {
        self.endLatitude = @(endLatitude);
    }
    double endLongitude = [[metadataDictionary objectForKey:kLongitudeEndKey] doubleValue];
    if (endLongitude != 0.0f) {
        self.endLongitude = @(endLongitude);
    }
    
    NSString *mediaURLString = [[metadataDictionary objectForKey:@"media_url"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (mediaURLString) {
        self.remoteMediaURLString = mediaURLString;
    }
    
    NSNumber *public = [metadataDictionary objectForKey:kPublicKey];
    if (public) {
        self.public = public;
    }
}

- (NSMutableDictionary*) metadataDictionary {
    NSMutableDictionary *newMetadataDictionary = [super metadataDictionary];
    if (self.uuid) {
        [newMetadataDictionary setObject:[self.uuid copy] forKey:kUUIDKey];
    }
    if ([OWLocationController locationIsValid:self.endLocation]) {
        [newMetadataDictionary setObject:self.endLatitude forKey:kLatitudeEndKey];
        [newMetadataDictionary setObject:self.endLongitude forKey:kLongitudeEndKey];
    }
    if (self.public) {
        [newMetadataDictionary setObject:self.public forKey:kPublicKey];
    }
    return newMetadataDictionary;
}

- (void) setEndLocation:(CLLocation *)endLocation {
    if (!endLocation) {
        return;
    }
    self.endLatitude = @(endLocation.coordinate.latitude);
    self.endLongitude = @(endLocation.coordinate.longitude);
}

+ (NSString*) mediaDirectoryPathForMediaType:(NSString *)mediaType {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString *suffix = mediaType;
    
    NSString *videosPath = [basePath stringByAppendingPathComponent:suffix];
    return videosPath;
}

+ (NSString *)newUUID
{
    NSUUID  *uuid = [NSUUID UUID];
    return [uuid UUIDString];
}

+ (NSString*) pathForUUID:(NSString*)uuid {
    NSString *mediaDirectoryPath = [self mediaDirectoryPath];
    NSString *mediaPath = [mediaDirectoryPath stringByAppendingPathComponent:uuid];
    return mediaPath;
}

- (NSString*) dataDirectory {
    return [[self class] pathForUUID:self.uuid];
}


+ (OWLocalMediaObject*) localMediaObjectWithUUID:(NSString *)uuid {
    OWLocalMediaObject *mediaObject = [[self class] MR_findFirstByAttribute:@"uuid" withValue:uuid];
    if (!mediaObject) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        mediaObject = [[self class] MR_createInContext:context];
        mediaObject.uuid = uuid;
        OWUser *user = [[[OWSettingsController sharedInstance] account] user];
        mediaObject.user = user;
        NSError *error = nil;
        BOOL success = [context obtainPermanentIDsForObjects:@[mediaObject] error:&error];
        if (error || !success) {
            NSLog(@"Error convert to permanent ID: %@", [error userInfo]);
        }
        [context MR_saveToPersistentStoreAndWait];
    }
    return mediaObject;
}

+ (OWLocalMediaObject*) localMediaObject {
    NSString *uuid = [self newUUID];
    OWLocalMediaObject* mediaObject = [self localMediaObjectWithUUID:uuid];
    return mediaObject;
}

// stub method, implement in subclasses
+ (NSString*) mediaDirectoryPath {
    return nil;
}

// stub method, implement in subclasses
- (NSString*) localMediaPath {
    return nil;
}

- (NSURL*) localMediaURL {
    return [NSURL fileURLWithPath:[self localMediaPath]];
}

- (NSURL*) remoteMediaURL {
    return [NSURL URLWithString:self.remoteMediaURLString];
}

- (BOOL) hasLocalData {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:self.localMediaPath];
}

@end
