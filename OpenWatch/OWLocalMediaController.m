//
//  OWLocalMediaController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/7/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWLocalMediaController.h"
#import "OWLocalRecording.h"
#import "OWRecordingController.h"
#import "OWPhoto.h"
#import "OWSettingsController.h"
#import "OWCaptureAPIClient.h"
#import "OWAudio.h"
#import "OWLocalRecording.h"
#import "OWAccountAPIClient.h"

@implementation OWLocalMediaController

+ (NSArray*) mediaObjectsForClass:(Class)class {
    OWSettingsController *settingsController = [OWSettingsController sharedInstance];
    
    OWUser *user = [settingsController.account user];
    NSArray *objects = [OWLocalMediaController allMediaObjectsForUser:user];
    
    NSMutableArray *recordingsArray = [NSMutableArray arrayWithCapacity:objects.count];
    
    for (OWMediaObject *object in user.objects) {
        if ([object isKindOfClass:class]) {
            [recordingsArray addObject:object.objectID];
        }
    }
    return recordingsArray;
}

+ (NSArray*) allMediaObjectsForUser:(OWUser*)user {
    NSSet *objects = user.objects;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:objects.count];
    for (OWMediaObject *object in objects) {
        if ([object isKindOfClass:[OWPhoto class]]) {
            [array addObject:object];
        } else if ([object isKindOfClass:[OWAudio class]]) {
            [array addObject:object];
        } else if ([object isKindOfClass:[OWManagedRecording class]]) {
            [array addObject:object];
        }
    }
    return array;
}

+ (void) scanDirectoryForChanges {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *mediaClasses = @[[OWLocalRecording class], [OWPhoto class]];
    
    for (Class class in mediaClasses) {
        NSError *error = nil;
        NSArray *recordingFileNames = [fileManager contentsOfDirectoryAtPath:[class mediaDirectoryPath] error:&error];
        if (error) {
            NSLog(@"Error loading directory of recordings: %@%@", [error localizedDescription], [error userInfo]);
            error = nil;
        }
        
        for (NSString *uuid in recordingFileNames) {
            OWLocalMediaObject *mediaObject = [class localMediaObjectWithUUID:uuid];
            NSLog(@"Recording created: %@", mediaObject.dataDirectory);
        }
    }
    [context MR_saveToPersistentStoreAndWait];
}

+ (void) removeLocalMediaObject:(NSManagedObjectID*)objectID {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWLocalMediaObject *mediaObject = [OWLocalMediaController localMediaObjectForObjectID:objectID];
    if (!mediaObject || !mediaObject.hasLocalData) {
        return;
    }
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:mediaObject.dataDirectory error:&error];
    if (error) {
        NSLog(@"Error removing mediaObject: %@%@", [error localizedDescription], [error userInfo]);
        error = nil;
    }
    [mediaObject MR_deleteEntity];
    [context MR_saveToPersistentStoreAndWait];
}

+ (void) scanDirectoryForUnsubmittedData {
    NSArray *mediaClasses = @[[OWLocalRecording class], [OWPhoto class]];
    
    for (Class class in mediaClasses) {
        NSArray *mediaObjectIDs = [self mediaObjectsForClass:class];
        for (NSManagedObjectID *mediaObjectID in mediaObjectIDs) {
            OWLocalMediaObject *mediaObject = [self localMediaObjectForObjectID:mediaObjectID];
            if ([mediaObject isKindOfClass:[OWLocalRecording class]]){
                OWLocalRecording *recording = (OWLocalRecording*)mediaObject;
                NSArray *failedURLs = recording.failedFileUploadURLs;
                //NSUInteger completed = recording.completedFileCount;
                //NSUInteger total = recording.totalFileCount;
                //NSLog(@"Progress for %@ %@: %d / %d, hq(%d), failed(%d), remoteMediaURL: %@", recording.title, recording.uuid, completed, total, recording.isHighQualityFileUploaded, failedURLs.count, recording.remoteMediaURLString);
                if (failedURLs.count > 0) {
                    for (NSURL *failedURL in failedURLs) {
                        NSLog(@"Failed URL: %@", failedURL.absoluteString);
                    }
                    NSLog(@"Unsubmitted data found for recording: %@", recording.localRecordingPath);
                    [[OWCaptureAPIClient sharedClient] uploadFailedFileURLs:failedURLs forRecording:recording.objectID];
                }
            } else if ([mediaObject isKindOfClass:[OWPhoto class]]) {
                OWPhoto *photo = (OWPhoto*)mediaObject;
                if (!photo.uploadedValue) {
                    [[OWAccountAPIClient sharedClient] postObjectWithUUID:photo.uuid objectClass:[photo class] success:nil failure:nil retryCount:kOWCaptureAPIClientDefaultRetryCount];
                }
            }

        }
    }
}

+ (OWLocalMediaObject*) localMediaObjectForObjectID:(NSManagedObjectID*)objectID {
    if (!objectID) {
        return nil;
    }
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWLocalMediaObject *mediaObject = (OWLocalMediaObject*)[context existingObjectWithID:objectID error:nil];
    return mediaObject;
}


@end
