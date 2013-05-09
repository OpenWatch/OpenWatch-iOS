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
        NSArray *mediaObjects = [self mediaObjectsForClass:class];
        for (OWLocalMediaObject *mediaObject in mediaObjects) {
            if ([mediaObject isKindOfClass:[OWLocalRecording class]]){
                OWLocalRecording *recording = (OWLocalRecording*)mediaObject;
                if (recording.completedFileCount != recording.totalFileCount) {
                    NSLog(@"Unsubmitted data found for recording: %@", recording.localRecordingPath);
                    [[OWCaptureAPIClient sharedClient] uploadFailedFileURLs:recording.failedFileUploadURLs forRecording:recording.objectID];
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
