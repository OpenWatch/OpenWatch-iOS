// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWLocalMediaObject.h instead.

#import <CoreData/CoreData.h>
#import "OWMediaObject.h"

extern const struct OWLocalMediaObjectAttributes {
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





@property (nonatomic, strong) NSString* uuid;



//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;






@end

@interface _OWLocalMediaObject (CoreDataGeneratedAccessors)

@end

@interface _OWLocalMediaObject (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;




@end
