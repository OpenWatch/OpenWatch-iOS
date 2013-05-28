// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWMission.h instead.

#import <CoreData/CoreData.h>
#import "OWMediaObject.h"

extern const struct OWMissionAttributes {
	__unsafe_unretained NSString *blurb;
	__unsafe_unretained NSString *bounty;
	__unsafe_unretained NSString *featured;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *primaryTag;
} OWMissionAttributes;

extern const struct OWMissionRelationships {
} OWMissionRelationships;

extern const struct OWMissionFetchedProperties {
} OWMissionFetchedProperties;









@interface OWMissionID : NSManagedObjectID {}
@end

@interface _OWMission : OWMediaObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWMissionID*)objectID;





@property (nonatomic, strong) NSString* blurb;



//- (BOOL)validateBlurb:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* bounty;



@property double bountyValue;
- (double)bountyValue;
- (void)setBountyValue:(double)value_;

//- (BOOL)validateBounty:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* featured;



@property BOOL featuredValue;
- (BOOL)featuredValue;
- (void)setFeaturedValue:(BOOL)value_;

//- (BOOL)validateFeatured:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* latitude;



@property double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* longitude;



@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* primaryTag;



//- (BOOL)validatePrimaryTag:(id*)value_ error:(NSError**)error_;






@end

@interface _OWMission (CoreDataGeneratedAccessors)

@end

@interface _OWMission (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBlurb;
- (void)setPrimitiveBlurb:(NSString*)value;




- (NSNumber*)primitiveBounty;
- (void)setPrimitiveBounty:(NSNumber*)value;

- (double)primitiveBountyValue;
- (void)setPrimitiveBountyValue:(double)value_;




- (NSNumber*)primitiveFeatured;
- (void)setPrimitiveFeatured:(NSNumber*)value;

- (BOOL)primitiveFeaturedValue;
- (void)setPrimitiveFeaturedValue:(BOOL)value_;




- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;




- (NSString*)primitivePrimaryTag;
- (void)setPrimitivePrimaryTag:(NSString*)value;




@end
