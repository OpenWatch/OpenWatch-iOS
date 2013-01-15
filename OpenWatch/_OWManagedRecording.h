// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWManagedRecording.h instead.

#import <CoreData/CoreData.h>
#import "OWMediaObject.h"

extern const struct OWManagedRecordingAttributes {
	__unsafe_unretained NSString *endDate;
	__unsafe_unretained NSString *endLatitude;
	__unsafe_unretained NSString *endLongitude;
	__unsafe_unretained NSString *recordingDescription;
	__unsafe_unretained NSString *remoteVideoURL;
	__unsafe_unretained NSString *startDate;
	__unsafe_unretained NSString *startLatitude;
	__unsafe_unretained NSString *startLongitude;
	__unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *uuid;
} OWManagedRecordingAttributes;

extern const struct OWManagedRecordingRelationships {
} OWManagedRecordingRelationships;

extern const struct OWManagedRecordingFetchedProperties {
} OWManagedRecordingFetchedProperties;













@interface OWManagedRecordingID : NSManagedObjectID {}
@end

@interface _OWManagedRecording : OWMediaObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWManagedRecordingID*)objectID;





@property (nonatomic, strong) NSDate* endDate;



//- (BOOL)validateEndDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* endLatitude;



@property double endLatitudeValue;
- (double)endLatitudeValue;
- (void)setEndLatitudeValue:(double)value_;

//- (BOOL)validateEndLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* endLongitude;



@property double endLongitudeValue;
- (double)endLongitudeValue;
- (void)setEndLongitudeValue:(double)value_;

//- (BOOL)validateEndLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* recordingDescription;



//- (BOOL)validateRecordingDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* remoteVideoURL;



//- (BOOL)validateRemoteVideoURL:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSString* thumbnailURL;



//- (BOOL)validateThumbnailURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uuid;



//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;






@end

@interface _OWManagedRecording (CoreDataGeneratedAccessors)

@end

@interface _OWManagedRecording (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveEndDate;
- (void)setPrimitiveEndDate:(NSDate*)value;




- (NSNumber*)primitiveEndLatitude;
- (void)setPrimitiveEndLatitude:(NSNumber*)value;

- (double)primitiveEndLatitudeValue;
- (void)setPrimitiveEndLatitudeValue:(double)value_;




- (NSNumber*)primitiveEndLongitude;
- (void)setPrimitiveEndLongitude:(NSNumber*)value;

- (double)primitiveEndLongitudeValue;
- (void)setPrimitiveEndLongitudeValue:(double)value_;




- (NSString*)primitiveRecordingDescription;
- (void)setPrimitiveRecordingDescription:(NSString*)value;




- (NSString*)primitiveRemoteVideoURL;
- (void)setPrimitiveRemoteVideoURL:(NSString*)value;




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




- (NSString*)primitiveThumbnailURL;
- (void)setPrimitiveThumbnailURL:(NSString*)value;




- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;




@end
