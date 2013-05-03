// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWTask.h instead.

#import <CoreData/CoreData.h>
#import "OWServerObject.h"

extern const struct OWTaskAttributes {
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *title;
} OWTaskAttributes;

extern const struct OWTaskRelationships {
	__unsafe_unretained NSString *investigation;
	__unsafe_unretained NSString *user;
} OWTaskRelationships;

extern const struct OWTaskFetchedProperties {
} OWTaskFetchedProperties;

@class OWInvestigation;
@class OWUser;




@interface OWTaskID : NSManagedObjectID {}
@end

@interface _OWTask : OWServerObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWTaskID*)objectID;





@property (nonatomic, strong) NSString* body;



//- (BOOL)validateBody:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *investigation;

- (NSMutableSet*)investigationSet;




@property (nonatomic, strong) OWUser *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@end

@interface _OWTask (CoreDataGeneratedAccessors)

- (void)addInvestigation:(NSSet*)value_;
- (void)removeInvestigation:(NSSet*)value_;
- (void)addInvestigationObject:(OWInvestigation*)value_;
- (void)removeInvestigationObject:(OWInvestigation*)value_;

@end

@interface _OWTask (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBody;
- (void)setPrimitiveBody:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (NSMutableSet*)primitiveInvestigation;
- (void)setPrimitiveInvestigation:(NSMutableSet*)value;



- (OWUser*)primitiveUser;
- (void)setPrimitiveUser:(OWUser*)value;


@end
