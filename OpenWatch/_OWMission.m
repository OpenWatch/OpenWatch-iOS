// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWMission.m instead.

#import "_OWMission.h"

const struct OWMissionAttributes OWMissionAttributes = {
	.active = @"active",
	.body = @"body",
	.completed = @"completed",
	.featured = @"featured",
	.karma = @"karma",
	.latitude = @"latitude",
	.longitude = @"longitude",
	.mediaURLString = @"mediaURLString",
	.primaryTag = @"primaryTag",
	.usd = @"usd",
	.viewed = @"viewed",
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
	
	if ([key isEqualToString:@"activeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"active"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"completedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"completed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"featuredValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"featured"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"karmaValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"karma"];
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
	if ([key isEqualToString:@"usdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"usd"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"viewedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"viewed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic active;



- (BOOL)activeValue {
	NSNumber *result = [self active];
	return [result boolValue];
}

- (void)setActiveValue:(BOOL)value_ {
	[self setActive:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveActiveValue {
	NSNumber *result = [self primitiveActive];
	return [result boolValue];
}

- (void)setPrimitiveActiveValue:(BOOL)value_ {
	[self setPrimitiveActive:[NSNumber numberWithBool:value_]];
}





@dynamic body;






@dynamic completed;



- (BOOL)completedValue {
	NSNumber *result = [self completed];
	return [result boolValue];
}

- (void)setCompletedValue:(BOOL)value_ {
	[self setCompleted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCompletedValue {
	NSNumber *result = [self primitiveCompleted];
	return [result boolValue];
}

- (void)setPrimitiveCompletedValue:(BOOL)value_ {
	[self setPrimitiveCompleted:[NSNumber numberWithBool:value_]];
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





@dynamic karma;



- (double)karmaValue {
	NSNumber *result = [self karma];
	return [result doubleValue];
}

- (void)setKarmaValue:(double)value_ {
	[self setKarma:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveKarmaValue {
	NSNumber *result = [self primitiveKarma];
	return [result doubleValue];
}

- (void)setPrimitiveKarmaValue:(double)value_ {
	[self setPrimitiveKarma:[NSNumber numberWithDouble:value_]];
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





@dynamic mediaURLString;






@dynamic primaryTag;






@dynamic usd;



- (double)usdValue {
	NSNumber *result = [self usd];
	return [result doubleValue];
}

- (void)setUsdValue:(double)value_ {
	[self setUsd:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveUsdValue {
	NSNumber *result = [self primitiveUsd];
	return [result doubleValue];
}

- (void)setPrimitiveUsdValue:(double)value_ {
	[self setPrimitiveUsd:[NSNumber numberWithDouble:value_]];
}





@dynamic viewed;



- (BOOL)viewedValue {
	NSNumber *result = [self viewed];
	return [result boolValue];
}

- (void)setViewedValue:(BOOL)value_ {
	[self setViewed:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveViewedValue {
	NSNumber *result = [self primitiveViewed];
	return [result boolValue];
}

- (void)setPrimitiveViewedValue:(BOOL)value_ {
	[self setPrimitiveViewed:[NSNumber numberWithBool:value_]];
}










@end
