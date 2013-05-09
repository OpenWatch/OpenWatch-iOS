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
#import "_OWManagedRecording.h"

#define kHQFileName @"hq.mp4"
#define kAllFilesKey @"all_files"
#define kUploadingKey @"uploading"
#define kFailedKey @"failed"
#define kCompletedKey @"completed"
#define kUploadStateKey @"upload_state"
#define kRecordingStartDateKey @"recording_start"
#define kRecordingEndDateKey @"recording_end"
#define kLatitudeStartKey @"start_lat"
#define kLongitudeStartKey @"start_lon"
#define kLatitudeEndKey @"end_lat"
#define kLongitudeEndKey @"end_lon"
#define kAltitudeKey @"altitude"
#define kRecordingKey @"recording"
#define kHorizontalAccuracyKey @"horizontal_accuracy"
#define kVerticalAccuracyKey @"vertical_accuracy"
#define kSpeedKey @"speed"
#define kCourseKey @"course"
#define kTimestampKey @"timestamp"
#define kDescriptionKey @"description"
#define kMetadataFileName @"metadata.json"
#define kSegmentsDirectory @"/segments/"
#define kLastEditedKey @"last_edited"

@class OWUser;

@interface OWManagedRecording : _OWManagedRecording

@property (nonatomic, strong) CLLocation *startLocation;

@end
