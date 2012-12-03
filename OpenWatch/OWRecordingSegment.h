//
//  OWRecordingSegment.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OWLocalRecording;

@interface OWRecordingSegment : NSManagedObject

@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSNumber * uploadState;
@property (nonatomic, retain) OWLocalRecording *recording;

@end
