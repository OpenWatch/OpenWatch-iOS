// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWMission.m instead.

#import "_OWMission.h"

const struct OWMissionAttributes OWMissionAttributes = {
	.blurb = @"blurb",
	.bounty = @"bounty",
	.featured = @"featured",
	.latitude = @"latitude",
	.longitude = @"longitude",
	.primaryTag = @"primaryTag",
};

const struct OWMissionRelationships OWMissionRelationships = {
};

const struct OWMissionFetchedProperties OWMissionFetchedProperties = {
};

@implementation OWMissionID
@end

@implementation _OWMission

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWMission" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWMission";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWMission" inManagedObjectContext:moc_];
}

- (OWMissionID*)objectID {
	return (OWMissionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"bountyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"bounty"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"featuredValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"featured"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"latitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"longitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic blurb;






@dynamic bounty;



- (double)bountyValue {
	NSNumber *result = [self bounty];
	return [result doubleValue];
}

- (void)setBountyValue:(double)value_ {
	[self setBounty:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveBountyValue {
	NSNumber *result = [self primitiveBounty];
	return [result doubleValue];
}

- (void)setPrimitiveBountyValue:(double)value_ {
	[self setPrimitiveBounty:[NSNumber numberWithDouble:value_]];
}





@dynamic featured;



- (BOOL)featuredValue {
	NSNumber *result = [self featured];
	return [result boolValue];
}

- (void)setFeaturedValue:(BOOL)value_ {
	[self setFeatured:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFeaturedValue {
	NSNumber *result = [self primitiveFeatured];
	return [result boolValue];
}

- (void)setPrimitiveFeaturedValue:(BOOL)value_ {
	[self setPrimitiveFeatured:[NSNumber numberWithBool:value_]];
}





@dynamic latitude;



- (double)latitudeValue {
	NSNumber *result = [self latitude];
	return [result doubleValue];
}

- (void)setLatitudeValue:(double)value_ {
	[self setLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLatitudeValue {
	NSNumber *result = [self primitiveLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveLatitudeValue:(double)value_ {
	[self setPrimitiveLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic longitude;



- (double)longitudeValue {
	NSNumber *result = [self longitude];
	return [result doubleValue];
}

- (void)setLongitudeValue:(double)value_ {
	[self setLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLongitudeValue {
	NSNumber *result = [self primitiveLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLongitudeValue:(double)value_ {
	[self setPrimitiveLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic primaryTag;











@end
