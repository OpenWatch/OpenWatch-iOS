// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWTag.h instead.

#import <CoreData/CoreData.h>


extern const struct OWTagAttributes {
	__unsafe_unretained NSString *isFeatured;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *serverID;
} OWTagAttributes;

extern const struct OWTagRelationships {
	__unsafe_unretained NSString *objects;
	__unsafe_unretained NSString *users;
} OWTagRelationships;

extern const struct OWTagFetchedProperties {
} OWTagFetchedProperties;

@class OWMediaObject;
@class OWUser;





@interface OWTagID : NSManagedObjectID {}
@end

@interface _OWTag : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWTagID*)objectID;





@property (nonatomic, strong) NSNumber* isFeatured;



@property BOOL isFeaturedValue;
- (BOOL)isFeaturedValue;
- (void)setIsFeaturedValue:(BOOL)value_;

//- (BOOL)validateIsFeatured:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* serverID;



@property int32_t serverIDValue;
- (int32_t)serverIDValue;
- (void)setServerIDValue:(int32_t)value_;

//- (BOOL)validateServerID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *objects;

- (NSMutableSet*)objectsSet;




@property (nonatomic, strong) OWUser *users;

//- (BOOL)validateUsers:(id*)value_ error:(NSError**)error_;





@end

@interface _OWTag (CoreDataGeneratedAccessors)

- (void)addObjects:(NSSet*)value_;
- (void)removeObjects:(NSSet*)value_;
- (void)addObjectsObject:(OWMediaObject*)value_;
- (void)removeObjectsObject:(OWMediaObject*)value_;

@end

@interface _OWTag (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsFeatured;
- (void)setPrimitiveIsFeatured:(NSNumber*)value;

- (BOOL)primitiveIsFeaturedValue;
- (void)setPrimitiveIsFeaturedValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveServerID;
- (void)setPrimitiveServerID:(NSNumber*)value;

- (int32_t)primitiveServerIDValue;
- (void)setPrimitiveServerIDValue:(int32_t)value_;





- (NSMutableSet*)primitiveObjects;
- (void)setPrimitiveObjects:(NSMutableSet*)value;



- (OWUser*)primitiveUsers;
- (void)setPrimitiveUsers:(OWUser*)value;


@end
