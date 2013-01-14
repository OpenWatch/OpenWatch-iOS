// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWRecordingSegment.h instead.

#import <CoreData/CoreData.h>


extern const struct OWRecordingSegmentAttributes {
	__unsafe_unretained NSString *fileName;
	__unsafe_unretained NSString *filePath;
	__unsafe_unretained NSString *uploadState;
} OWRecordingSegmentAttributes;

extern const struct OWRecordingSegmentRelationships {
	__unsafe_unretained NSString *recording;
} OWRecordingSegmentRelationships;

extern const struct OWRecordingSegmentFetchedProperties {
} OWRecordingSegmentFetchedProperties;

@class OWLocalRecording;





@interface OWRecordingSegmentID : NSManagedObjectID {}
@end

@interface _OWRecordingSegment : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWRecordingSegmentID*)objectID;





@property (nonatomic, strong) NSString* fileName;



//- (BOOL)validateFileName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* filePath;



//- (BOOL)validateFilePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* uploadState;



@property int16_t uploadStateValue;
- (int16_t)uploadStateValue;
- (void)setUploadStateValue:(int16_t)value_;

//- (BOOL)validateUploadState:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) OWLocalRecording *recording;

//- (BOOL)validateRecording:(id*)value_ error:(NSError**)error_;





@end

@interface _OWRecordingSegment (CoreDataGeneratedAccessors)

@end

@interface _OWRecordingSegment (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveFileName;
- (void)setPrimitiveFileName:(NSString*)value;




- (NSString*)primitiveFilePath;
- (void)setPrimitiveFilePath:(NSString*)value;




- (NSNumber*)primitiveUploadState;
- (void)setPrimitiveUploadState:(NSNumber*)value;

- (int16_t)primitiveUploadStateValue;
- (void)setPrimitiveUploadStateValue:(int16_t)value_;





- (OWLocalRecording*)primitiveRecording;
- (void)setPrimitiveRecording:(OWLocalRecording*)value;


@end
