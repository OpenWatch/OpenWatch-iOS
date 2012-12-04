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

@class OWUser;

@interface OWManagedRecording : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;

@property (nonatomic, retain) NSString * recordingDescription;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * serverID;
@property (nonatomic, retain) NSString * remoteVideoURL;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, strong) OWUser *user;

@property (nonatomic, strong) CLLocation *startLocation;
@property (nonatomic, strong) CLLocation *endLocation;

- (void) saveMetadata;


@end

@interface OWManagedRecording (CoreDataGeneratedAccessors)

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
