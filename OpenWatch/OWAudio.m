//
//  OWAudio.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/7/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWAudio.h"

#define kAudioName @"audio.caf"

@implementation OWAudio

- (NSString*) localMediaPath {
    NSString *uuidPath = [OWAudio pathForUUID:self.uuid];
    NSString *path = [uuidPath stringByAppendingPathComponent:kAudioName];
    return path;
}

+ (NSString*) mediaDirectoryPath {
    return [self mediaDirectoryPathForMediaType:@"audio"];
}

+ (OWAudio*) audioWithUUID:(NSString*)uuid {
    OWLocalMediaObject *mediaObject = [OWLocalMediaObject localMediaObjectWithUUID:uuid];
    return (OWAudio*)mediaObject;
}

+ (OWAudio*) audio {
    OWAudio* audio = (OWAudio*)[self localMediaObject];
    audio.uploaded = @(NO);
    return audio;
}

- (NSString*) type {
    return @"audio";
}

@end

