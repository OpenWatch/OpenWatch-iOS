//
//  OWRecordingTag.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/7/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OWManagedRecording, OWUser;

@interface OWRecordingTag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *recordings;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) NSNumber *isFeatured;

@end

@interface OWRecordingTag (CoreDataGeneratedAccessors)

- (void)addRecordingsObject:(OWManagedRecording *)value;
- (void)removeRecordingsObject:(OWManagedRecording *)value;
- (void)addRecordings:(NSSet *)values;
- (void)removeRecordings:(NSSet *)values;

- (void)addUsersObject:(OWUser *)value;
- (void)removeUsersObject:(OWUser *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;


@end
