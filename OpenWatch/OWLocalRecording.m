//
//  OWLocalRecording.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWLocalRecording.h"
#import "OWSettingsController.h"
#import "OWCaptureAPIClient.h"

#define kHQFileName @"hq.mp4"
#define kAllFilesKey @"all_files"
#define kUploadingKey @"uploading"
#define kFailedKey @"failed"
#define kCompletedKey @"completed"
#define kUploadStateKey @"upload_state"
#define kRecordingStartDateKey @"recording_start"
#define kRecordingEndDateKey @"recording_end"
#define kLocationStartKey @"start_location"
#define kLocationEndKey @"end_location"
#define kLatitudeKey @"latitude"
#define kLongitudeKey @"longitude"
#define kAltitudeKey @"altitude"
#define kRecordingKey @"recording"
#define kHorizontalAccuracyKey @"horizontal_accuracy"
#define kVerticalAccuracyKey @"vertical_accuracy"
#define kSpeedKey @"speed"
#define kCourseKey @"course"
#define kTimestampKey @"timestamp"
#define kTitleKey @"title"
#define kDescriptionKey @"description"
#define kUUIDKey @"uuid"
#define kMetadataFileName @"metadata.json"

@implementation OWLocalRecording

@dynamic localRecordingPath;
@dynamic hqFileUploadState;
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
        OWUser *user = [[[OWSettingsController sharedInstance] account] user];
        recording.user = user;
        [MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
            OWLocalRecording *localRecording = [recording MR_inContext:localContext];
            localRecording.localRecordingPath = path;
            localRecording.user = user;
        }];
    }
    return recording;
}

- (void) setUploadState:(OWFileUploadState)uploadState forFileAtURL :(NSURL *)url {
    NSString *path = [url path];
    
    if ([[path lastPathComponent] isEqualToString:kHQFileName]) {
        self.hqFileUploadState = @(uploadState);
        [MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
            OWLocalRecording *localRecording = [self MR_inContext:localContext];
            localRecording.hqFileUploadState = @(uploadState);
        }];
        return;
    }
    
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
        [self addSegmentsObject:segment];
    }
}

- (OWFileUploadState)uploadStateForFileAtURL:(NSURL*)url {
    NSString *path = [url path];
    
    if ([[path lastPathComponent] isEqualToString:kHQFileName]) {
        return [self.hqFileUploadState unsignedIntegerValue];
    }
    
    OWRecordingSegment *segment = [OWRecordingSegment MR_findFirstByAttribute:@"filePath" withValue:path];
    if (!segment) {
        return OWFileUploadStateUnknown;
    }
    return segment.fileUploadState;
}


- (NSDictionary*) dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self newMetadataDictionary]];
    NSMutableArray *allFiles = [NSMutableArray array];
    
    for (OWRecordingSegment *segment in self.segments) {
        [allFiles addObject:segment.fileName];
    }
    
    [dictionary setObject:allFiles forKey:kAllFilesKey];
    return dictionary;
}

- (NSDictionary*) newMetadataDictionary {
    NSMutableDictionary *newMetadataDictionary = [NSMutableDictionary dictionary];
    if (self.uuid) {
        [newMetadataDictionary setObject:[self.uuid copy] forKey:kUUIDKey];
    }
    if (self.startDate) {
        [newMetadataDictionary setObject:@([self.startDate timeIntervalSince1970]) forKey:kRecordingStartDateKey];
    }
    if (self.endDate) {
        [newMetadataDictionary setObject:@([self.endDate timeIntervalSince1970]) forKey:kRecordingEndDateKey];
    }
    if (self.title) {
        [newMetadataDictionary setObject:[self.title copy] forKey:kTitleKey];
    }
    if (self.recordingDescription) {
        [newMetadataDictionary setObject:[self.recordingDescription copy] forKey:kDescriptionKey];
    }
    if ([self locationIsValid:self.startLocation]) {
        NSDictionary *startLocationDictionary = [self locationDictionaryForLocation:self.startLocation];
        [newMetadataDictionary setObject:startLocationDictionary forKey:kLocationStartKey];
    }
    if ([self locationIsValid:self.endLocation]) {
        NSDictionary *endLocationDictionary = [self locationDictionaryForLocation:self.endLocation];
        [newMetadataDictionary setObject:endLocationDictionary forKey:kLocationEndKey];
    }
    return newMetadataDictionary;
}

- (BOOL) locationIsValid:(CLLocation*)location {
    if (location.coordinate.latitude == 0.0f && location.coordinate.longitude == 0.0f) {
        return NO;
    }
    return YES;
}

- (NSDictionary*) locationDictionaryForLocation:(CLLocation*)location {
    NSMutableDictionary *locationDictionary = [NSMutableDictionary dictionaryWithCapacity:8];
    [locationDictionary setObject:@(location.coordinate.latitude) forKey:kLatitudeKey];
    [locationDictionary setObject:@(location.coordinate.longitude) forKey:kLongitudeKey];
    [locationDictionary setObject:@(location.altitude) forKey:kAltitudeKey];
    [locationDictionary setObject:@(location.horizontalAccuracy) forKey:kHorizontalAccuracyKey];
    [locationDictionary setObject:@(location.verticalAccuracy) forKey:kVerticalAccuracyKey];
    [locationDictionary setObject:@(location.speed) forKey:kSpeedKey];
    [locationDictionary setObject:@(location.course) forKey:kCourseKey];
    [locationDictionary setObject:@([location.timestamp timeIntervalSince1970]) forKey:kTimestampKey];
    return locationDictionary;
}

- (void) saveMetadata {
    [MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext) {
        OWLocalRecording *localRecording = [self MR_inContext:localContext];
        localRecording.title = self.title;
        localRecording.uuid = self.uuid;
        localRecording.startLocation = self.startLocation;
        localRecording.endLocation = self.endLocation;
        localRecording.localRecordingPath = self.localRecordingPath;
        
    }];
}

- (void) checkIntegrity {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *recordingFileNames = [fileManager contentsOfDirectoryAtPath:self.localRecordingPath error:&error];
    if (error) {
        NSLog(@"Error getting contents of recording directory: %@", self.localRecordingPath);
    }
        
    BOOL dataHasChanged = NO;
    
    for (NSString *fileName in recordingFileNames) {
        if ([fileName rangeOfString:@"mp4"].location != NSNotFound) {
            NSString *videoPath = [self.localRecordingPath stringByAppendingPathComponent:fileName];
            NSURL *url = [NSURL URLWithString:videoPath];
            OWFileUploadState state = [self uploadStateForFileAtURL:url];
            if (state == OWFileUploadStateUnknown) {
                NSLog(@"Unrecognized file found (%@): %@", self.localRecordingPath, videoPath);
                [self setUploadState:OWFileUploadStateFailed forFileAtURL:url];
                dataHasChanged = YES;
            }
        }
    }
    if (dataHasChanged) {
        [self saveMetadata];
    }
}


- (void) loadMetadataFromDictionary:(NSDictionary*)metadataDictionary {
    NSString *newUUID = [metadataDictionary objectForKey:kUUIDKey];
    if (newUUID) {
        self.uuid = newUUID;
    }
    NSString *newTitle = [metadataDictionary objectForKey:kTitleKey];
    if (newTitle) {
        self.title = newTitle;
    }
    NSString *newDescription = [metadataDictionary objectForKey:kDescriptionKey];
    if (newDescription) {
        self.recordingDescription = newDescription;
    }
    NSNumber *startDateTimestampNumber = [metadataDictionary objectForKey:kRecordingStartDateKey];
    if (startDateTimestampNumber) {
        self.startDate = [NSDate dateWithTimeIntervalSince1970:[startDateTimestampNumber doubleValue]];
    }
    NSNumber *endDateTimestampNumber = [metadataDictionary objectForKey:kRecordingEndDateKey];
    if (endDateTimestampNumber) {
        self.endDate = [NSDate dateWithTimeIntervalSince1970:[endDateTimestampNumber doubleValue]];
    }
    NSDictionary *startLocationDictionary = [metadataDictionary objectForKey:kLocationStartKey];
    if (startLocationDictionary) {
        self.startLocation = [self locationFromLocationDictionary:startLocationDictionary];
    }
    NSDictionary *endLocationDictionary = [metadataDictionary objectForKey:kLocationEndKey];
    if (endLocationDictionary) {
        self.endLocation = [self locationFromLocationDictionary:endLocationDictionary];
    }
}

- (CLLocation*)locationFromLocationDictionary:(NSDictionary*)locationDictionary {
    CLLocationDegrees latitude = [[locationDictionary objectForKey:kLatitudeKey] doubleValue];
    CLLocationDegrees longitude = [[locationDictionary objectForKey:kLongitudeKey] doubleValue];
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

- (void) startLocationUpdated:(CLLocation *)location {
    self.startLocation = location;
    [self saveMetadata];
    [[OWCaptureAPIClient sharedClient] updateMetadataForRecording:self];
}

- (void) startRecording {
    self.startDate = [NSDate date];
    self.uuid = [self newUUID];
    [[OWLocationControler sharedInstance] startWithDelegate:self];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if (![fileManager fileExistsAtPath:recordingPath isDirectory:&isDirectory]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:recordingPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Error creating directory: %@%@", [error localizedDescription], [error userInfo]);
        }
    }
    isRecording = YES;
    [self saveMetadata];
    [[OWCaptureAPIClient sharedClient] startedRecording:self];
}

- (void) stopRecording {
    self.endDate = [NSDate date];
    isRecording = NO;
    self.endLocation = [OWLocationControler sharedInstance].currentLocation;
    [[OWLocationControler sharedInstance] stop];
    [self saveMetadata];
    [[OWCaptureAPIClient sharedClient] finishedRecording:self];
    [[OWCaptureAPIClient sharedClient] updateMetadataForRecording:self];
}

- (NSURL*) highQualityURL {
    NSString *movieName = kHQFileName;
    NSString *path = [recordingPath stringByAppendingPathComponent:movieName];
    NSURL *newMovieURL = [NSURL fileURLWithPath:path];
    return newMovieURL;
}

- (NSURL*) urlForNextSegment {
    NSString *movieName = [NSString stringWithFormat:@"%d.mp4", segmentCount];
    NSString *path = [recordingPath stringByAppendingPathComponent:movieName];
    NSURL *newMovieURL = [NSURL fileURLWithPath:path];
    segmentCount++;
    return newMovieURL;
}

- (NSUInteger) failedFileCount {
    return [failedDictionary count];
}

- (NSUInteger) completedFileCount {
    return [completedDictionary count];
}

- (NSUInteger) totalFileCount {
    return [self failedFileCount] + [self completedFileCount] + [self recordingFileCount] + [self uploadingFileCount];
}

- (NSUInteger) recordingFileCount {
    return [recordingDictionary count];
}

- (NSUInteger) uploadingFileCount {
    return [uploadingDictionary count];
}

- (BOOL) isHighQualityFileUploaded {
    return [completedDictionary objectForKey:kHQFileName] != nil;
}

- (NSArray*) failedFileUploadURLs {
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:[failedDictionary count]];
    for (NSString *fileName in [failedDictionary allKeys]) {
        NSString *path = [recordingPath stringByAppendingPathComponent:fileName];
        [urls addObject:[NSURL fileURLWithPath:path]];
    }
    return urls;
}


@end
