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

@implementation OWLocalMediaObject


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
