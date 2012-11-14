//
//  OWRecordingController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWRecording.h"

@interface OWRecordingController : NSObject


+ (OWRecordingController *)sharedInstance;

- (NSArray*) allRecordings;

- (void) addRecording:(OWRecording*)recording;
- (void) removeRecording:(OWRecording*)recording;

- (void) scanDirectoryForChanges;
- (void) scanRecordingsForUnsubmittedData;

@end
