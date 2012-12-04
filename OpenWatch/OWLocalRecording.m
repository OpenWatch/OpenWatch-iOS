//
//  OWLocalRecording.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWLocalRecording.h"


@implementation OWLocalRecording

@dynamic localRecordingPath;
@dynamic isHQFileSynced;
@dynamic segments;

- (NSString *)newUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge_transfer NSString *)string;
}

+ (OWLocalRecording*) recordingWithPath:(NSString *)path {
    OWLocalRecording *recording = [OWLocalRecording MR_findFirstByAttribute:@"localRecordingPath" withValue:path];
    if (!recording) {
        recording = [OWLocalRecording MR_createEntity];
        recording.localRecordingPath = path;
    }
    return recording;
}

- (void) setUploadState:(OWFileUploadState)uploadState forFileAtURL :(NSURL *)url {
    NSString *path = [url path];
    OWRecordingSegment *segment = [OWRecordingSegment MR_findFirstByAttribute:@"filePath" withValue:path];
    if (segment) {
        [MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
            OWRecordingSegment *localSegment = [segment MR_inContext:localContext];
            localSegment.fileUploadState = uploadState;            
        }];
    } else {
        segment = [OWRecordingSegment MR_createEntity];
        [MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
            OWRecordingSegment *localSegment = [segment MR_inContext:localContext];
            localSegment.filePath = path;
            localSegment.fileUploadState = uploadState;
            
        }];
    }
}

- (OWFileUploadState)uploadStateForFileAtURL:(NSURL*)url {
    OWRecordingSegment *segment = [OWRecordingSegment MR_findFirstByAttribute:@"filePath" withValue:[url path]];
    if (!segment) {
        return OWFileUploadStateUnknown;
    }
    return segment.fileUploadState;
}

@end
