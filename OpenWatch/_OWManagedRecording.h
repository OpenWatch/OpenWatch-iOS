// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWManagedRecording.h instead.

#import <CoreData/CoreData.h>
#import "OWLocalMediaObject.h"

extern const struct OWManagedRecordingAttributes {
	__unsafe_unretained NSString *endDate;
	__unsafe_unretained NSString *recordingDescription;
	__unsafe_unretained NSString *startDate;
	__unsafe_unretained NSString *startLatitude;
	__unsafe_unretained NSString *startLongitude;
} OWManagedRecordingAttributes;

extern const struct OWManagedRecordingRelationships {
} OWManagedRecordingRelationships;

extern const struct OWManagedRecordingFetchedProperties {
} OWManagedRecordingFetchedProperties;








@interface OWManagedRecordingID : NSManagedObjectID {}
@end

@interface _OWManagedRecording : OWLocalMediaObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWManagedRecordingID*)objectID;





@property (nonatomic, strong) NSDate* endDate;



//- (BOOL)validateEndDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* recordingDescription;



//- (BOOL)validateRecordingDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* startDate;



//- (BOOL)validateStartDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* startLatitude;



@property double startLatitudeValue;
- (double)startLatitudeValue;
- (void)setStartLatitudeValue:(double)value_;

//- (BOOL)validateStartLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* startLongitude;



@property double startLongitudeValue;
- (double)startLongitudeValue;
- (void)setStartLongitudeValue:(double)value_;

//- (BOOL)validateStartLongitude:(id*)value_ error:(NSError**)error_;






@end

@interface _OWManagedRecording (CoreDataGeneratedAccessors)

@end

@interface _OWManagedRecording (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveEndDate;
- (void)setPrimitiveEndDate:(NSDate*)value;




- (NSString*)primitiveRecordingDescription;
- (void)setPrimitiveRecordingDescription:(NSString*)value;




- (NSDate*)primitiveStartDate;
- (void)setPrimitiveStartDate:(NSDate*)value;




- (NSNumber*)primitiveStartLatitude;
- (void)setPrimitiveStartLatitude:(NSNumber*)value;

- (double)primitiveStartLatitudeValue;
- (void)setPrimitiveStartLatitudeValue:(double)value_;




- (NSNumber*)primitiveStartLongitude;
- (void)setPrimitiveStartLongitude:(NSNumber*)value;

- (double)primitiveStartLongitudeValue;
- (void)setPrimitiveStartLongitudeValue:(double)value_;




@end
