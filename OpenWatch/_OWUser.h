// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWUser.h instead.

#import <CoreData/CoreData.h>
#import "OWServerObject.h"

extern const struct OWUserAttributes {
	__unsafe_unretained NSString *bio;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *thumbnailURLString;
	__unsafe_unretained NSString *username;
} OWUserAttributes;

extern const struct OWUserRelationships {
	__unsafe_unretained NSString *objects;
	__unsafe_unretained NSString *tags;
	__unsafe_unretained NSString *tasks;
} OWUserRelationships;

extern const struct OWUserFetchedProperties {
} OWUserFetchedProperties;

@class OWMediaObject;
@class OWTag;
@class OWTask;







@interface OWUserID : NSManagedObjectID {}
@end

@interface _OWUser : OWServerObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWUserID*)objectID;





@property (nonatomic, strong) NSString* bio;



//- (BOOL)validateBio:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* firstName;



//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* lastName;



//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailURLString;



//- (BOOL)validateThumbnailURLString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *objects;

- (NSMutableSet*)objectsSet;




@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;




@property (nonatomic, strong) NSSet *tasks;

- (NSMutableSet*)tasksSet;





@end

@interface _OWUser (CoreDataGeneratedAccessors)

- (void)addObjects:(NSSet*)value_;
- (void)removeObjects:(NSSet*)value_;
- (void)addObjectsObject:(OWMediaObject*)value_;
- (void)removeObjectsObject:(OWMediaObject*)value_;

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(OWTag*)value_;
- (void)removeTagsObject:(OWTag*)value_;

- (void)addTasks:(NSSet*)value_;
- (void)removeTasks:(NSSet*)value_;
- (void)addTasksObject:(OWTask*)value_;
- (void)removeTasksObject:(OWTask*)value_;

@end

@interface _OWUser (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBio;
- (void)setPrimitiveBio:(NSString*)value;




- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;




- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;




- (NSString*)primitiveThumbnailURLString;
- (void)setPrimitiveThumbnailURLString:(NSString*)value;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;





- (NSMutableSet*)primitiveObjects;
- (void)setPrimitiveObjects:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTasks;
- (void)setPrimitiveTasks:(NSMutableSet*)value;


@end
