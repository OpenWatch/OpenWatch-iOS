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
#import "OWLocalMediaController.h"

@interface OWRecordingController()
@end

@implementation OWRecordingController

+ (OWLocalRecording*) localRecordingForObjectID:(NSManagedObjectID*)objectID {
    OWLocalRecording *recording = (OWLocalRecording*)[OWLocalMediaController localMediaObjectForObjectID:objectID];
    if ([recording isKindOfClass:[OWLocalRecording class]]) {
        return (OWLocalRecording*)recording;
    }
    return nil;
}

+ (OWManagedRecording*) recordingForObjectID:(NSManagedObjectID*)objectID {
    OWManagedRecording *recording = (OWManagedRecording*)[OWLocalMediaController localMediaObjectForObjectID:objectID];
    if ([recording isKindOfClass:[OWManagedRecording class]]) {
        return (OWManagedRecording*)recording;
    }
    return nil;
}

+ (NSURL*) detailPageURLForRecordingServerID:(int)serverID {
    NSString *urlString = [[OWUtilities apiBaseURLString] stringByAppendingFormat:@"v/%d/",serverID];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}



+ (NSArray*) allManagedRecordings {
    return [OWLocalMediaController mediaObjectsForClass:[OWManagedRecording class]];
}

+ (NSArray*) allLocalRecordings {
    return [OWLocalMediaController mediaObjectsForClass:[OWLocalRecording class]];
}

@end
