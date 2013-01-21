// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWTag.h instead.

#import <CoreData/CoreData.h>
#import "OWServerObject.h"

extern const struct OWTagAttributes {
	__unsafe_unretained NSString *isFeatured;
	__unsafe_unretained NSString *name;
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

@interface _OWTag : OWServerObject {}
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





@property (nonatomic, strong) NSSet *objects;

- (NSMutableSet*)objectsSet;




@property (nonatomic, strong) NSSet *users;

- (NSMutableSet*)usersSet;





@end

@interface _OWTag (CoreDataGeneratedAccessors)

- (void)addObjects:(NSSet*)value_;
- (void)removeObjects:(NSSet*)value_;
- (void)addObjectsObject:(OWMediaObject*)value_;
- (void)removeObjectsObject:(OWMediaObject*)value_;

- (void)addUsers:(NSSet*)value_;
- (void)removeUsers:(NSSet*)value_;
- (void)addUsersObject:(OWUser*)value_;
- (void)removeUsersObject:(OWUser*)value_;

@end

@interface _OWTag (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsFeatured;
- (void)setPrimitiveIsFeatured:(NSNumber*)value;

- (BOOL)primitiveIsFeaturedValue;
- (void)setPrimitiveIsFeaturedValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveObjects;
- (void)setPrimitiveObjects:(NSMutableSet*)value;



- (NSMutableSet*)primitiveUsers;
- (void)setPrimitiveUsers:(NSMutableSet*)value;


@end
