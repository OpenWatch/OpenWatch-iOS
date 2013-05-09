// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWLocalMediaObject.m instead.

#import "_OWLocalMediaObject.h"

const struct OWLocalMediaObjectAttributes OWLocalMediaObjectAttributes = {
	.endLatitude = @"endLatitude",
	.endLongitude = @"endLongitude",
	.remoteMediaURLString = @"remoteMediaURLString",
	.uploaded = @"uploaded",
	.uuid = @"uuid",
};

const struct OWLocalMediaObjectRelationships OWLocalMediaObjectRelationships = {
};

const struct OWLocalMediaObjectFetchedProperties OWLocalMediaObjectFetchedProperties = {
};

@implementation OWLocalMediaObjectID
@end

@implementation _OWLocalMediaObject

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWLocalMediaObject" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWLocalMediaObject";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWLocalMediaObject" inManagedObjectContext:moc_];
}

- (OWLocalMediaObjectID*)objectID {
	return (OWLocalMediaObjectID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"endLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"endLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"endLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"endLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"uploadedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"uploaded"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic endLatitude;



- (double)endLatitudeValue {
	NSNumber *result = [self endLatitude];
	return [result doubleValue];
}

- (void)setEndLatitudeValue:(double)value_ {
	[self setEndLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveEndLatitudeValue {
	NSNumber *result = [self primitiveEndLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveEndLatitudeValue:(double)value_ {
	[self setPrimitiveEndLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic endLongitude;



- (double)endLongitudeValue {
	NSNumber *result = [self endLongitude];
	return [result doubleValue];
}

- (void)setEndLongitudeValue:(double)value_ {
	[self setEndLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveEndLongitudeValue {
	NSNumber *result = [self primitiveEndLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveEndLongitudeValue:(double)value_ {
	[self setPrimitiveEndLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic remoteMediaURLString;






@dynamic uploaded;



- (BOOL)uploadedValue {
	NSNumber *result = [self uploaded];
	return [result boolValue];
}

- (void)setUploadedValue:(BOOL)value_ {
	[self setUploaded:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveUploadedValue {
	NSNumber *result = [self primitiveUploaded];
	return [result boolValue];
}

- (void)setPrimitiveUploadedValue:(BOOL)value_ {
	[self setPrimitiveUploaded:[NSNumber numberWithBool:value_]];
}





@dynamic uuid;











@end
