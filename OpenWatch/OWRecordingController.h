//
//  OWRecordingController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWLocalRecording.h"

@interface OWRecordingController : NSObject


+ (OWRecordingController *)sharedInstance;

- (NSArray*) allRecordings;

- (void) addRecording:(OWLocalRecording*)recording;
- (void) removeRecording:(OWLocalRecording*)recording;

- (void) scanDirectoryForChanges;
- (void) scanRecordingsForUnsubmittedData;

@end
