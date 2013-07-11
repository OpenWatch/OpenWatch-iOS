// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWLocalMediaObject.h instead.

#import <CoreData/CoreData.h>
#import "OWMediaObject.h"

extern const struct OWLocalMediaObjectAttributes {
	__unsafe_unretained NSString *endLatitude;
	__unsafe_unretained NSString *endLongitude;
	__unsafe_unretained NSString *public;
	__unsafe_unretained NSString *remoteMediaURLString;
	__unsafe_unretained NSString *uploaded;
	__unsafe_unretained NSString *uuid;
} OWLocalMediaObjectAttributes;

extern const struct OWLocalMediaObjectRelationships {
} OWLocalMediaObjectRelationships;

extern const struct OWLocalMediaObjectFetchedProperties {
} OWLocalMediaObjectFetchedProperties;









@interface OWLocalMediaObjectID : NSManagedObjectID {}
@end

@interface _OWLocalMediaObject : OWMediaObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWLocalMediaObjectID*)objectID;





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





@property (nonatomic, strong) NSNumber* public;



@property BOOL publicValue;
- (BOOL)publicValue;
- (void)setPublicValue:(BOOL)value_;

//- (BOOL)validatePublic:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* remoteMediaURLString;



//- (BOOL)validateRemoteMediaURLString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* uploaded;



@property BOOL uploadedValue;
- (BOOL)uploadedValue;
- (void)setUploadedValue:(BOOL)value_;

//- (BOOL)validateUploaded:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uuid;



//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;






@end

@interface _OWLocalMediaObject (CoreDataGeneratedAccessors)

@end

@interface _OWLocalMediaObject (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveEndLatitude;
- (void)setPrimitiveEndLatitude:(NSNumber*)value;

- (double)primitiveEndLatitudeValue;
- (void)setPrimitiveEndLatitudeValue:(double)value_;




- (NSNumber*)primitiveEndLongitude;
- (void)setPrimitiveEndLongitude:(NSNumber*)value;

- (double)primitiveEndLongitudeValue;
- (void)setPrimitiveEndLongitudeValue:(double)value_;




- (NSNumber*)primitivePublic;
- (void)setPrimitivePublic:(NSNumber*)value;

- (BOOL)primitivePublicValue;
- (void)setPrimitivePublicValue:(BOOL)value_;




- (NSString*)primitiveRemoteMediaURLString;
- (void)setPrimitiveRemoteMediaURLString:(NSString*)value;




- (NSNumber*)primitiveUploaded;
- (void)setPrimitiveUploaded:(NSNumber*)value;

- (BOOL)primitiveUploadedValue;
- (void)setPrimitiveUploadedValue:(BOOL)value_;




- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;




@end
