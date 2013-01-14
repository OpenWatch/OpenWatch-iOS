// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWMediaObject.h instead.

#import <CoreData/CoreData.h>
#import "OWServerObject.h"

extern const struct OWMediaObjectAttributes {
	__unsafe_unretained NSString *clicks;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *views;
} OWMediaObjectAttributes;

extern const struct OWMediaObjectRelationships {
	__unsafe_unretained NSString *tags;
	__unsafe_unretained NSString *user;
} OWMediaObjectRelationships;

extern const struct OWMediaObjectFetchedProperties {
} OWMediaObjectFetchedProperties;

@class OWTag;
@class OWUser;





@interface OWMediaObjectID : NSManagedObjectID {}
@end

@interface _OWMediaObject : OWServerObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWMediaObjectID*)objectID;





@property (nonatomic, strong) NSNumber* clicks;



@property int32_t clicksValue;
- (int32_t)clicksValue;
- (void)setClicksValue:(int32_t)value_;

//- (BOOL)validateClicks:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* views;



@property int32_t viewsValue;
- (int32_t)viewsValue;
- (void)setViewsValue:(int32_t)value_;

//- (BOOL)validateViews:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;




@property (nonatomic, strong) OWUser *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@end

@interface _OWMediaObject (CoreDataGeneratedAccessors)

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(OWTag*)value_;
- (void)removeTagsObject:(OWTag*)value_;

@end

@interface _OWMediaObject (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveClicks;
- (void)setPrimitiveClicks:(NSNumber*)value;

- (int32_t)primitiveClicksValue;
- (void)setPrimitiveClicksValue:(int32_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSNumber*)primitiveViews;
- (void)setPrimitiveViews:(NSNumber*)value;

- (int32_t)primitiveViewsValue;
- (void)setPrimitiveViewsValue:(int32_t)value_;





- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;



- (OWUser*)primitiveUser;
- (void)setPrimitiveUser:(OWUser*)value;


@end
