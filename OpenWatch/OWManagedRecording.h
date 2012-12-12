//
//  OWManagedRecording.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

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
#define kSegmentsDirectory @"/segments/"

@class OWUser;

@interface OWManagedRecording : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * recordingDescription;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * serverID;
@property (nonatomic, retain) NSString * remoteVideoURL;
@property (nonatomic, retain) NSString *thumbnailURL;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, strong) OWUser *user;

@property (nonatomic, strong) NSNumber *upvotes;
@property (nonatomic, strong) NSNumber *views;

@property (nonatomic, strong) CLLocation *startLocation;
@property (nonatomic, strong) CLLocation *endLocation;

- (void) saveMetadata;
- (NSDictionary*) metadataDictionary;
- (void) loadMetadataFromDictionary:(NSDictionary*)metadataDictionary;


- (CLLocation*)locationFromLocationDictionary:(NSDictionary*)locationDictionary;
- (NSDictionary*) locationDictionaryForLocation:(CLLocation*)location;

@end

@interface OWManagedRecording (CoreDataGeneratedAccessors)

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
