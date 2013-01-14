// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWLocalRecording.h instead.

#import <CoreData/CoreData.h>
#import "OWManagedRecording.h"

extern const struct OWLocalRecordingAttributes {
	__unsafe_unretained NSString *hqFileUploadState;
	__unsafe_unretained NSString *localRecordingPath;
} OWLocalRecordingAttributes;

extern const struct OWLocalRecordingRelationships {
	__unsafe_unretained NSString *segments;
} OWLocalRecordingRelationships;

extern const struct OWLocalRecordingFetchedProperties {
} OWLocalRecordingFetchedProperties;

@class OWRecordingSegment;




@interface OWLocalRecordingID : NSManagedObjectID {}
@end

@interface _OWLocalRecording : OWManagedRecording {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWLocalRecordingID*)objectID;





@property (nonatomic, strong) NSNumber* hqFileUploadState;



@property int16_t hqFileUploadStateValue;
- (int16_t)hqFileUploadStateValue;
- (void)setHqFileUploadStateValue:(int16_t)value_;

//- (BOOL)validateHqFileUploadState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* localRecordingPath;



//- (BOOL)validateLocalRecordingPath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *segments;

- (NSMutableSet*)segmentsSet;





@end

@interface _OWLocalRecording (CoreDataGeneratedAccessors)

- (void)addSegments:(NSSet*)value_;
- (void)removeSegments:(NSSet*)value_;
- (void)addSegmentsObject:(OWRecordingSegment*)value_;
- (void)removeSegmentsObject:(OWRecordingSegment*)value_;

@end

@interface _OWLocalRecording (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveHqFileUploadState;
- (void)setPrimitiveHqFileUploadState:(NSNumber*)value;

- (int16_t)primitiveHqFileUploadStateValue;
- (void)setPrimitiveHqFileUploadStateValue:(int16_t)value_;




- (NSString*)primitiveLocalRecordingPath;
- (void)setPrimitiveLocalRecordingPath:(NSString*)value;





- (NSMutableSet*)primitiveSegments;
- (void)setPrimitiveSegments:(NSMutableSet*)value;


@end
