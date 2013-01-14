// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWStory.h instead.

#import <CoreData/CoreData.h>
#import "OWMediaObject.h"

extern const struct OWStoryAttributes {
	__unsafe_unretained NSString *blurb;
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *slug;
} OWStoryAttributes;

extern const struct OWStoryRelationships {
} OWStoryRelationships;

extern const struct OWStoryFetchedProperties {
} OWStoryFetchedProperties;






@interface OWStoryID : NSManagedObjectID {}
@end

@interface _OWStory : OWMediaObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWStoryID*)objectID;





@property (nonatomic, strong) NSString* blurb;



//- (BOOL)validateBlurb:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* body;



//- (BOOL)validateBody:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* slug;



//- (BOOL)validateSlug:(id*)value_ error:(NSError**)error_;






@end

@interface _OWStory (CoreDataGeneratedAccessors)

@end

@interface _OWStory (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBlurb;
- (void)setPrimitiveBlurb:(NSString*)value;




- (NSString*)primitiveBody;
- (void)setPrimitiveBody:(NSString*)value;




- (NSString*)primitiveSlug;
- (void)setPrimitiveSlug:(NSString*)value;




@end
