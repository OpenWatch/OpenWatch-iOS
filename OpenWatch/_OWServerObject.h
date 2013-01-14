// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWServerObject.h instead.

#import <CoreData/CoreData.h>


extern const struct OWServerObjectAttributes {
	__unsafe_unretained NSString *serverID;
} OWServerObjectAttributes;

extern const struct OWServerObjectRelationships {
} OWServerObjectRelationships;

extern const struct OWServerObjectFetchedProperties {
} OWServerObjectFetchedProperties;




@interface OWServerObjectID : NSManagedObjectID {}
@end

@interface _OWServerObject : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWServerObjectID*)objectID;





@property (nonatomic, strong) NSNumber* serverID;



@property int32_t serverIDValue;
- (int32_t)serverIDValue;
- (void)setServerIDValue:(int32_t)value_;

//- (BOOL)validateServerID:(id*)value_ error:(NSError**)error_;






@end

@interface _OWServerObject (CoreDataGeneratedAccessors)

@end

@interface _OWServerObject (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveServerID;
- (void)setPrimitiveServerID:(NSNumber*)value;

- (int32_t)primitiveServerIDValue;
- (void)setPrimitiveServerIDValue:(int32_t)value_;




@end
