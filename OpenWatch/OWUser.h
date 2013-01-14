//
//  OWUser.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "_OWUser.h"

@class OWManagedRecording, OWRecordingTag;

@interface OWUser : _OWUser

- (NSURL*) thumbnailURL;

@end

@interface OWUser (CoreDataGeneratedAccessors)

- (void)addRecordingsObject:(OWManagedRecording *)value;
- (void)removeRecordingsObject:(OWManagedRecording *)value;
- (void)addRecordings:(NSSet *)values;
- (void)removeRecordings:(NSSet *)values;

- (void)addTagsObject:(OWRecordingTag *)value;
- (void)removeTagsObject:(OWRecordingTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
