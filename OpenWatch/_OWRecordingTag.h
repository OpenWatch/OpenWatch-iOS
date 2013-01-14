// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWRecordingTag.h instead.

#import <CoreData/CoreData.h>


extern const struct OWRecordingTagAttributes {
	__unsafe_unretained NSString *isFeatured;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *serverID;
} OWRecordingTagAttributes;

extern const struct OWRecordingTagRelationships {
	__unsafe_unretained NSString *objects;
	__unsafe_unretained NSString *users;
} OWRecordingTagRelationships;

extern const struct OWRecordingTagFetchedProperties {
} OWRecordingTagFetchedProperties;

@class OWMediaObject;
@class OWUser;





@interface OWRecordingTagID : NSManagedObjectID {}
@end

@interface _OWRecordingTag : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWRecordingTagID*)objectID;





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

@interface _OWRecordingTag (CoreDataGeneratedAccessors)

- (void)addObjects:(NSSet*)value_;
- (void)removeObjects:(NSSet*)value_;
- (void)addObjectsObject:(OWMediaObject*)value_;
- (void)removeObjectsObject:(OWMediaObject*)value_;

@end

@interface _OWRecordingTag (CoreDataGeneratedPrimitiveAccessors)


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
