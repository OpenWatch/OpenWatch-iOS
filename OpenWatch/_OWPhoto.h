// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWPhoto.h instead.

#import <CoreData/CoreData.h>
#import "OWLocalMediaObject.h"

extern const struct OWPhotoAttributes {
	__unsafe_unretained NSString *uploaded;
} OWPhotoAttributes;

extern const struct OWPhotoRelationships {
} OWPhotoRelationships;

extern const struct OWPhotoFetchedProperties {
} OWPhotoFetchedProperties;




@interface OWPhotoID : NSManagedObjectID {}
@end

@interface _OWPhoto : OWLocalMediaObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWPhotoID*)objectID;





@property (nonatomic, strong) NSNumber* uploaded;



@property BOOL uploadedValue;
- (BOOL)uploadedValue;
- (void)setUploadedValue:(BOOL)value_;

//- (BOOL)validateUploaded:(id*)value_ error:(NSError**)error_;






@end

@interface _OWPhoto (CoreDataGeneratedAccessors)

@end

@interface _OWPhoto (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveUploaded;
- (void)setPrimitiveUploaded:(NSNumber*)value;

- (BOOL)primitiveUploadedValue;
- (void)setPrimitiveUploadedValue:(BOOL)value_;




@end
