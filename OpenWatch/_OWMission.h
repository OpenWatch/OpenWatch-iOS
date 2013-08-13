// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWMission.h instead.

#import <CoreData/CoreData.h>
#import "OWMediaObject.h"

extern const struct OWMissionAttributes {
	__unsafe_unretained NSString *active;
	__unsafe_unretained NSString *agents;
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *completed;
	__unsafe_unretained NSString *expirationDate;
	__unsafe_unretained NSString *featured;
	__unsafe_unretained NSString *joined;
	__unsafe_unretained NSString *karma;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *mediaURLString;
	__unsafe_unretained NSString *primaryTag;
	__unsafe_unretained NSString *submissions;
	__unsafe_unretained NSString *usd;
	__unsafe_unretained NSString *viewed;
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





@property (nonatomic, strong) NSNumber* active;



@property BOOL activeValue;
- (BOOL)activeValue;
- (void)setActiveValue:(BOOL)value_;

//- (BOOL)validateActive:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* agents;



@property int32_t agentsValue;
- (int32_t)agentsValue;
- (void)setAgentsValue:(int32_t)value_;

//- (BOOL)validateAgents:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* body;



//- (BOOL)validateBody:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* completed;



@property BOOL completedValue;
- (BOOL)completedValue;
- (void)setCompletedValue:(BOOL)value_;

//- (BOOL)validateCompleted:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* expirationDate;



//- (BOOL)validateExpirationDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* featured;



@property BOOL featuredValue;
- (BOOL)featuredValue;
- (void)setFeaturedValue:(BOOL)value_;

//- (BOOL)validateFeatured:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* joined;



//- (BOOL)validateJoined:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* karma;



@property double karmaValue;
- (double)karmaValue;
- (void)setKarmaValue:(double)value_;

//- (BOOL)validateKarma:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSString* mediaURLString;



//- (BOOL)validateMediaURLString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* primaryTag;



//- (BOOL)validatePrimaryTag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* submissions;



@property int32_t submissionsValue;
- (int32_t)submissionsValue;
- (void)setSubmissionsValue:(int32_t)value_;

//- (BOOL)validateSubmissions:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* usd;



@property double usdValue;
- (double)usdValue;
- (void)setUsdValue:(double)value_;

//- (BOOL)validateUsd:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* viewed;



@property BOOL viewedValue;
- (BOOL)viewedValue;
- (void)setViewedValue:(BOOL)value_;

//- (BOOL)validateViewed:(id*)value_ error:(NSError**)error_;






@end

@interface _OWMission (CoreDataGeneratedAccessors)

@end

@interface _OWMission (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveActive;
- (void)setPrimitiveActive:(NSNumber*)value;

- (BOOL)primitiveActiveValue;
- (void)setPrimitiveActiveValue:(BOOL)value_;




- (NSNumber*)primitiveAgents;
- (void)setPrimitiveAgents:(NSNumber*)value;

- (int32_t)primitiveAgentsValue;
- (void)setPrimitiveAgentsValue:(int32_t)value_;




- (NSString*)primitiveBody;
- (void)setPrimitiveBody:(NSString*)value;




- (NSNumber*)primitiveCompleted;
- (void)setPrimitiveCompleted:(NSNumber*)value;

- (BOOL)primitiveCompletedValue;
- (void)setPrimitiveCompletedValue:(BOOL)value_;




- (NSDate*)primitiveExpirationDate;
- (void)setPrimitiveExpirationDate:(NSDate*)value;




- (NSNumber*)primitiveFeatured;
- (void)setPrimitiveFeatured:(NSNumber*)value;

- (BOOL)primitiveFeaturedValue;
- (void)setPrimitiveFeaturedValue:(BOOL)value_;




- (NSDate*)primitiveJoined;
- (void)setPrimitiveJoined:(NSDate*)value;




- (NSNumber*)primitiveKarma;
- (void)setPrimitiveKarma:(NSNumber*)value;

- (double)primitiveKarmaValue;
- (void)setPrimitiveKarmaValue:(double)value_;




- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;




- (NSString*)primitiveMediaURLString;
- (void)setPrimitiveMediaURLString:(NSString*)value;




- (NSString*)primitivePrimaryTag;
- (void)setPrimitivePrimaryTag:(NSString*)value;




- (NSNumber*)primitiveSubmissions;
- (void)setPrimitiveSubmissions:(NSNumber*)value;

- (int32_t)primitiveSubmissionsValue;
- (void)setPrimitiveSubmissionsValue:(int32_t)value_;




- (NSNumber*)primitiveUsd;
- (void)setPrimitiveUsd:(NSNumber*)value;

- (double)primitiveUsdValue;
- (void)setPrimitiveUsdValue:(double)value_;




- (NSNumber*)primitiveViewed;
- (void)setPrimitiveViewed:(NSNumber*)value;

- (BOOL)primitiveViewedValue;
- (void)setPrimitiveViewedValue:(BOOL)value_;




@end
