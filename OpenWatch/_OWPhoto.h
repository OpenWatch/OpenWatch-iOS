// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWPhoto.h instead.

#import <CoreData/CoreData.h>
#import "OWLocalMediaObject.h"

extern const struct OWPhotoAttributes {
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






@end

@interface _OWPhoto (CoreDataGeneratedAccessors)

@end

@interface _OWPhoto (CoreDataGeneratedPrimitiveAccessors)


@end
