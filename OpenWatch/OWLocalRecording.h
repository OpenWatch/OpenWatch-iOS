//
//  OWLocalRecording.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OWManagedRecording.h"


@interface OWLocalRecording : OWManagedRecording

@property (nonatomic, retain) NSString * localRecordingPath;
@property (nonatomic, retain) NSNumber * isHQFileSynced;
@property (nonatomic, retain) NSSet *segments;
@end

@interface OWLocalRecording (CoreDataGeneratedAccessors)

- (void)addSegmentsObject:(NSManagedObject *)value;
- (void)removeSegmentsObject:(NSManagedObject *)value;
- (void)addSegments:(NSSet *)values;
- (void)removeSegments:(NSSet *)values;

@end
