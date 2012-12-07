//
//  OWRecordingTag.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/7/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OWManagedRecording;

@interface OWRecordingTag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *recordings;
@end

@interface OWRecordingTag (CoreDataGeneratedAccessors)

- (void)addRecordingsObject:(OWManagedRecording *)value;
- (void)removeRecordingsObject:(OWManagedRecording *)value;
- (void)addRecordings:(NSSet *)values;
- (void)removeRecordings:(NSSet *)values;

@end
