//
//  OWRecordingController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWRecordingController.h"
#import "OWCaptureAPIClient.h"
#import "OWSettingsController.h"
#import "OWUtilities.h"


@interface OWRecordingController()
@end

@implementation OWRecordingController

+ (OWRecordingController *)sharedInstance {
    static OWRecordingController *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[OWRecordingController alloc] init];
    });
    return _sharedClient;
}

- (id) init {
    if (self = [super init]) {
        [self scanDirectoryForChanges];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self scanRecordingsForUnsubmittedData];
        });
    }
    return self;
}

- (void) scanRecordingsForUnsubmittedData {
    for (NSManagedObjectID *objectID in [self allLocalRecordings]) {
        OWLocalRecording *recording = [OWRecordingController localRecordingForObjectID:objectID];
        if (![recording isKindOfClass:[OWLocalRecording class]]){
            continue;
        }
        if (recording.completedFileCount != recording.totalFileCount) {
            NSLog(@"Unsubmitted data found for recording: %@", recording.localRecordingPath);
            [self uploadFailedFileURLs:recording.failedFileUploadURLs forRecording:recording.objectID];
        }
    }
}


+ (OWLocalRecording*) localRecordingForObjectID:(NSManagedObjectID*)objectID {
    OWManagedRecording *recording = [OWRecordingController recordingForObjectID:objectID];
    if ([recording isKindOfClass:[OWLocalRecording class]]) {
        return (OWLocalRecording*)recording;
    }
    return nil;
}

+ (OWManagedRecording*) recordingForObjectID:(NSManagedObjectID*)objectID {
    if (!objectID) {
        return nil;
    }
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSError *error = nil;
    OWManagedRecording *recording = (OWManagedRecording*)[context existingObjectWithID:objectID error:&error];
    if (error) {
        NSLog(@"Error: %@", [error userInfo]);
        error = nil;
    }
    return recording;
}

+ (NSURL*) detailPageURLForRecordingServerID:(int)serverID {
    NSString *urlString = [[OWUtilities apiBaseURLString] stringByAppendingFormat:@"v/%d/",serverID];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (void) uploadFailedFileURLs:(NSArray*)failedFileURLs forRecording:(NSManagedObjectID*)recordingObjectID {
    for (NSURL *url in failedFileURLs) {
        [[OWCaptureAPIClient sharedClient] uploadFileURL:url recording:recordingObjectID priority:NSOperationQueuePriorityVeryLow];
    }
}

- (void) removeRecording:(NSManagedObjectID*)recordingObjectID {
    OWLocalRecording *recording = [OWRecordingController localRecordingForObjectID:recordingObjectID];
    if (!recording || ![recording isKindOfClass:[OWLocalRecording class]]) {
        return;
    }
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:recording.localRecordingPath error:&error];
    if (error) {
        NSLog(@"Error removing recording: %@%@", [error localizedDescription], [error userInfo]);
        error = nil;
    }
    [recording MR_deleteEntity];
}

- (NSArray*) allMediaObjectsForUser:(OWUser*)user {
    NSSet *objects = user.objects;
    return [objects allObjects];

}

- (NSArray*) mediaObjectsForClass:(Class)class {
    OWSettingsController *settingsController = [OWSettingsController sharedInstance];
    
    OWUser *user = [settingsController.account user];
    NSArray *objects = [self allMediaObjectsForUser:user];
    
    NSMutableArray *recordingsArray = [NSMutableArray arrayWithCapacity:objects.count];
    
    for (OWMediaObject *object in user.objects) {
        if ([object isKindOfClass:class]) {
            [recordingsArray addObject:object.objectID];
        }
    }
    return recordingsArray;
}

- (NSArray*) allManagedRecordings {
    return [self mediaObjectsForClass:[OWManagedRecording class]];
}

- (NSArray*) allLocalRecordings {
    return [self mediaObjectsForClass:[OWLocalRecording class]];
}

- (void) scanDirectoryForChanges {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSError *error = nil;
    NSArray *recordingFileNames = [fileManager contentsOfDirectoryAtPath:basePath error:&error];
    if (error) {
        NSLog(@"Error loading directory of recordings: %@%@", [error localizedDescription], [error userInfo]);
        error = nil;
    }
    
    NSArray *currentRecordings = [self allLocalRecordings];
    
    for (NSManagedObjectID *recordingID in currentRecordings) {
        OWLocalRecording *recording = [OWRecordingController localRecordingForObjectID:recordingID];

        if (![recording isKindOfClass:[OWLocalRecording class]]) {
            continue;
        }
        if (![fileManager fileExistsAtPath:recording.localRecordingPath]) {
            NSLog(@"Recording no longer exists, removing: %@", recording.localRecordingPath);
            [context deleteObject:recording];
        }
    }
    
    for (NSString *recordingFileName in recordingFileNames) {
        if ([recordingFileName rangeOfString:@"recording"].location != NSNotFound) {
            NSString *recordingPath = [basePath stringByAppendingPathComponent:recordingFileName];
            OWLocalRecording *recording = [OWLocalRecording recordingWithPath:recordingPath];
            NSLog(@"Recording created: %@", recording.localRecordingPath);
        }
    }
    [context MR_saveToPersistentStoreAndWait];
}

@end
