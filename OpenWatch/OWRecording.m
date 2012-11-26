//
//  OWRecording
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWRecording.h"
#import "JSONKit.h"
#import "OWCaptureAPIClient.h"

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
#define kAllFilesKey @"all_files"

@interface OWRecording()
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *recordingPath;
@property (nonatomic) NSUInteger segmentCount;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic) BOOL isRecording;

@property (nonatomic, strong) NSMutableDictionary *metadataDictionary;
@property (nonatomic, strong) NSMutableDictionary *completedDictionary;
@property (nonatomic, strong) NSMutableDictionary *uploadingDictionary;
@property (nonatomic, strong) NSMutableDictionary *failedDictionary;
@property (nonatomic, strong) NSMutableDictionary *recordingDictionary;
@end

@implementation OWRecording
@synthesize uuid, metadataDictionary, recordingPath, segmentCount, startDate, endDate, title, recordingDescription, startLocation, endLocation, completedDictionary, uploadingDictionary, failedDictionary, recordingDictionary, isRecording;


- (id) initWithRecordingPath:(NSString*)path {
    if (self = [super init]) {
        self.recordingPath = path;
        self.segmentCount = 0;
        self.completedDictionary = [NSMutableDictionary dictionary];
        self.uploadingDictionary = [NSMutableDictionary dictionary];
        self.failedDictionary = [NSMutableDictionary dictionary];
        self.metadataDictionary = [NSMutableDictionary dictionary];
        self.recordingDictionary = [NSMutableDictionary dictionary];
        isRecording = NO;
        [self loadMetadata];
        [self checkIntegrity];
    }
    return self;
}

- (NSString *)newUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge_transfer NSString *)string;
}

- (NSString*) metadataFilePath {
    return [recordingPath stringByAppendingPathComponent:(NSString*)kMetadataFileName];
}

- (void) setUploadState:(OWFileUploadState)uploadState forFileAtURL :(NSURL *)url {
    NSString *key = [[url absoluteString] lastPathComponent];
    [uploadingDictionary removeObjectForKey:key];
    [failedDictionary removeObjectForKey:key];
    [completedDictionary removeObjectForKey:key];
    [recordingDictionary removeObjectForKey:key];
    
    if (uploadState == OWFileUploadStateUploading) {
        [uploadingDictionary setObject:kUploadingKey forKey:key];
    } else if (uploadState == OWFileUploadStateCompleted) {
        [completedDictionary setObject:kCompletedKey forKey:key];
    } else if (uploadState == OWFileUploadStateFailed) {
        [failedDictionary setObject:kFailedKey forKey:key];
    } else if (uploadState == OWFileUploadStateRecording) {
        [recordingDictionary setObject:kRecordingKey forKey:key];
    }
    [self saveMetadata];
}

- (OWFileUploadState)uploadStateForFileAtURL:(NSURL*)url {
    NSString *key = [[url absoluteString] lastPathComponent];
    if ([uploadingDictionary objectForKey:key]) {
        return OWFileUploadStateUploading;
    } else if ([completedDictionary objectForKey:key]) {
        return OWFileUploadStateCompleted;
    } else if ([failedDictionary objectForKey:key]) {
        return OWFileUploadStateFailed;
    } else if ([recordingDictionary objectForKey:key]) {
        return OWFileUploadStateRecording;
    }
    return OWFileUploadStateUnknown;
}

- (NSDictionary*) dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self newMetadataDictionary]];
    NSMutableArray *allFiles = [NSMutableArray array];
    NSMutableDictionary *allFilesDictionary = [NSMutableDictionary dictionary];
    [allFilesDictionary addEntriesFromDictionary:completedDictionary];
    [allFilesDictionary addEntriesFromDictionary:failedDictionary];
    [allFilesDictionary addEntriesFromDictionary:uploadingDictionary];
    [allFilesDictionary addEntriesFromDictionary:recordingDictionary];
    [allFilesDictionary removeObjectForKey:@"hq.mp4"];
    [allFiles addObjectsFromArray:[allFilesDictionary allKeys]];
    [dictionary setObject:allFiles forKey:kAllFilesKey];
    return dictionary;
}

- (NSDictionary*) newMetadataDictionary {
    NSMutableDictionary *newMetadataDictionary = [NSMutableDictionary dictionary];
    if (uuid) {
        [newMetadataDictionary setObject:[uuid copy] forKey:kUUIDKey];
    }
    if (startDate) {
        [newMetadataDictionary setObject:@([startDate timeIntervalSince1970]) forKey:kRecordingStartDateKey];
    }
    if (endDate) {
        [newMetadataDictionary setObject:@([endDate timeIntervalSince1970]) forKey:kRecordingEndDateKey];
    }
    if (title) {
        [newMetadataDictionary setObject:[title copy] forKey:kTitleKey];
    }
    if (recordingDescription) {
        [newMetadataDictionary setObject:[recordingDescription copy] forKey:kDescriptionKey];
    }
    if (startLocation) {
        NSDictionary *startLocationDictionary = [self locationDictionaryForLocation:startLocation];
        [newMetadataDictionary setObject:startLocationDictionary forKey:kLocationStartKey];
    }
    if (endLocation) {
        NSDictionary *endLocationDictionary = [self locationDictionaryForLocation:endLocation];
        [newMetadataDictionary setObject:endLocationDictionary forKey:kLocationEndKey];
    }
    [newMetadataDictionary setObject:[completedDictionary copy] forKey:kCompletedKey];
    [newMetadataDictionary setObject:[uploadingDictionary copy] forKey:kUploadingKey];
    [newMetadataDictionary setObject:[failedDictionary copy] forKey:kFailedKey];
    [newMetadataDictionary setObject:[recordingDictionary copy] forKey:kRecordingKey];
    return newMetadataDictionary;
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
    @synchronized(self) {
        NSError *error = nil;
        NSDictionary *dictionary = [self newMetadataDictionary];
        NSData *jsonData = [dictionary JSONDataWithOptions:JKSerializeOptionPretty error:&error];
        if (error) {
            NSLog(@"Error serializing JSON: %@%@", [error localizedDescription], [error userInfo]);
            error = nil;
        }
        if (!jsonData) {
            NSLog(@"JSON data is nil!");
            return;
        }
        [jsonData writeToFile:[self metadataFilePath] options:NSDataWritingAtomic error:&error];
        if (error) {
            NSLog(@"Error writing metadata to file: %@%@", [error localizedDescription], [error userInfo]);
            error = nil;
        }

    }
}

- (void) checkIntegrity {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *recordingFileNames = [fileManager contentsOfDirectoryAtPath:self.recordingPath error:&error];
    if (error) {
        NSLog(@"Error getting contents of recording directory: %@", recordingPath);
    }
    
    NSDictionary *fileNameDictionary = [NSDictionary dictionaryWithObjects:recordingFileNames forKeys:recordingFileNames];
    
    BOOL dataHasChanged = NO;
    
    for (NSString *fileName in recordingFileNames) {
        if ([fileName rangeOfString:@"mp4"].location != NSNotFound) {
            NSString *videoPath = [recordingPath stringByAppendingPathComponent:fileName];
            NSURL *url = [NSURL URLWithString:videoPath];
            OWFileUploadState state = [self uploadStateForFileAtURL:url];
            if (state == OWFileUploadStateUnknown) {
                NSLog(@"Unrecognized file found (%@): %@", recordingPath, videoPath);
                [self setUploadState:OWFileUploadStateFailed forFileAtURL:url];
                dataHasChanged = YES;
            }
        }
    }
    dataHasChanged = dataHasChanged || [self pruneFileDictionary:completedDictionary againstFileNameDictionary:fileNameDictionary];
    dataHasChanged = dataHasChanged || [self pruneFileDictionary:failedDictionary againstFileNameDictionary:fileNameDictionary];
    if (dataHasChanged) {
        [self saveMetadata];
    }
}

- (BOOL) pruneFileDictionary:(NSMutableDictionary*)dictionary againstFileNameDictionary:(NSDictionary*)fileNameDictionary {
    NSArray *fileDictionaryKeys = [dictionary allKeys];
    BOOL dataHasChanged = NO;
    for (NSString *key in fileDictionaryKeys) {
        if (![fileNameDictionary objectForKey:key]) {
            NSLog(@"File not found (%@): %@", recordingPath, key);
            [dictionary removeObjectForKey:key];
            dataHasChanged = YES;
        }
    }
    return dataHasChanged;
}

- (void) loadMetadata {
    NSString *metadataFilePath = [self metadataFilePath];
    NSData *rawMetadata = [NSData dataWithContentsOfFile:metadataFilePath];
    if (!rawMetadata) {
        NSLog(@"Error loading metadata.json: %@", metadataFilePath);
        return;
    }
    JSONDecoder *decoder = [JSONDecoder decoder];
    NSError *error = nil;
    NSDictionary *metadata = [decoder objectWithData:rawMetadata error:&error];
    if (error) {
        NSLog(@"Error loading metadata: %@%@", [error localizedDescription], [error userInfo]);
        error = nil;
    }
    self.metadataDictionary = [NSMutableDictionary dictionaryWithDictionary:metadata];
    self.completedDictionary = [NSMutableDictionary dictionaryWithDictionary:[self.metadataDictionary objectForKey:kCompletedKey]];
    self.failedDictionary = [NSMutableDictionary dictionaryWithDictionary:[self.metadataDictionary objectForKey:kFailedKey]];
    [failedDictionary addEntriesFromDictionary:[self.metadataDictionary objectForKey:kUploadingKey]];
    [failedDictionary addEntriesFromDictionary:[self.metadataDictionary objectForKey:kRecordingKey]];
    NSString *newUUID = [self.metadataDictionary objectForKey:kUUIDKey];
    if (newUUID) {
        self.uuid = newUUID;
    }
    NSString *newTitle = [self.metadataDictionary objectForKey:kTitleKey];
    if (newTitle) {
        self.title = newTitle;
    }
    NSString *newDescription = [self.metadataDictionary objectForKey:kDescriptionKey];
    if (newDescription) {
        self.recordingDescription = newDescription;
    }
    NSNumber *startDateTimestampNumber = [self.metadataDictionary objectForKey:kRecordingStartDateKey];
    if (startDateTimestampNumber) {
        self.startDate = [NSDate dateWithTimeIntervalSince1970:[startDateTimestampNumber doubleValue]];
    }
    NSNumber *endDateTimestampNumber = [self.metadataDictionary objectForKey:kRecordingEndDateKey];
    if (endDateTimestampNumber) {
        self.endDate = [NSDate dateWithTimeIntervalSince1970:[endDateTimestampNumber doubleValue]];
    }
    NSDictionary *startLocationDictionary = [self.metadataDictionary objectForKey:kLocationStartKey];
    if (startLocationDictionary) {
        self.startLocation = [self locationFromLocationDictionary:startLocationDictionary];
    }
    NSDictionary *endLocationDictionary = [self.metadataDictionary objectForKey:kLocationEndKey];
    if (endLocationDictionary) {
        self.endLocation = [self locationFromLocationDictionary:endLocationDictionary];
    }
    if (!metadataDictionary) {
        self.metadataDictionary = [NSMutableDictionary dictionary];
    }
}

- (CLLocation*)locationFromLocationDictionary:(NSDictionary*)locationDictionary {
    CLLocationDegrees latitude = [[locationDictionary objectForKey:kLatitudeKey] doubleValue];
    CLLocationDegrees longitude = [[locationDictionary objectForKey:kLongitudeKey] doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDistance altitude = [[locationDictionary objectForKey:kAltitudeKey] doubleValue];
    CLLocationDistance horizontalAccuracy = [[locationDictionary objectForKey:kHorizontalAccuracyKey] doubleValue];
    CLLocationDistance verticalAccuracy = [[locationDictionary objectForKey:kVerticalAccuracyKey] doubleValue];
    CLLocationSpeed speed = [[locationDictionary objectForKey:kSpeedKey] doubleValue];
    CLLocationDirection course = [[locationDictionary objectForKey:kCourseKey] doubleValue];
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:[[locationDictionary objectForKey:kTimestampKey] doubleValue]];
    return [[CLLocation alloc] initWithCoordinate:coordinate altitude:altitude horizontalAccuracy:horizontalAccuracy verticalAccuracy:verticalAccuracy course:course speed:speed timestamp:timestamp];
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
    NSString *movieName = @"hq.mp4";
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

- (NSUInteger) failedFileUploadCount {
    return [failedDictionary count];
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
