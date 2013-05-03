// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWInvestigation.h instead.

#import <CoreData/CoreData.h>
#import "OWMediaObject.h"

extern const struct OWInvestigationAttributes {
	__unsafe_unretained NSString *bigLogo;
	__unsafe_unretained NSString *blurb;
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *html;
	__unsafe_unretained NSString *questions;
} OWInvestigationAttributes;

extern const struct OWInvestigationRelationships {
	__unsafe_unretained NSString *tasks;
} OWInvestigationRelationships;

extern const struct OWInvestigationFetchedProperties {
} OWInvestigationFetchedProperties;

@class OWTask;







@interface OWInvestigationID : NSManagedObjectID {}
@end

@interface _OWInvestigation : OWMediaObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWInvestigationID*)objectID;





@property (nonatomic, strong) NSString* bigLogo;



//- (BOOL)validateBigLogo:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* blurb;



//- (BOOL)validateBlurb:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* body;



//- (BOOL)validateBody:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* html;



//- (BOOL)validateHtml:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* questions;



//- (BOOL)validateQuestions:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *tasks;

- (NSMutableSet*)tasksSet;





@end

@interface _OWInvestigation (CoreDataGeneratedAccessors)

- (void)addTasks:(NSSet*)value_;
- (void)removeTasks:(NSSet*)value_;
- (void)addTasksObject:(OWTask*)value_;
- (void)removeTasksObject:(OWTask*)value_;

@end

@interface _OWInvestigation (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBigLogo;
- (void)setPrimitiveBigLogo:(NSString*)value;




- (NSString*)primitiveBlurb;
- (void)setPrimitiveBlurb:(NSString*)value;




- (NSString*)primitiveBody;
- (void)setPrimitiveBody:(NSString*)value;




- (NSString*)primitiveHtml;
- (void)setPrimitiveHtml:(NSString*)value;




- (NSString*)primitiveQuestions;
- (void)setPrimitiveQuestions:(NSString*)value;





- (NSMutableSet*)primitiveTasks;
- (void)setPrimitiveTasks:(NSMutableSet*)value;


@end
