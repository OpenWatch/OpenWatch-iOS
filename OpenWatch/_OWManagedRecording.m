// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWManagedRecording.m instead.

#import "_OWManagedRecording.h"

const struct OWManagedRecordingAttributes OWManagedRecordingAttributes = {
	.dateModified = @"dateModified",
	.endDate = @"endDate",
	.endLatitude = @"endLatitude",
	.endLongitude = @"endLongitude",
	.recordingDescription = @"recordingDescription",
	.remoteVideoURL = @"remoteVideoURL",
	.startDate = @"startDate",
	.startLatitude = @"startLatitude",
	.startLongitude = @"startLongitude",
	.thumbnailURL = @"thumbnailURL",
	.uuid = @"uuid",
};

const struct OWManagedRecordingRelationships OWManagedRecordingRelationships = {
};

const struct OWManagedRecordingFetchedProperties OWManagedRecordingFetchedProperties = {
};

@implementation OWManagedRecordingID
@end

@implementation _OWManagedRecording

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWManagedRecording" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWManagedRecording";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWManagedRecording" inManagedObjectContext:moc_];
}

- (OWManagedRecordingID*)objectID {
	return (OWManagedRecordingID*)[super objectID];
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
	if ([key isEqualToString:@"startLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"startLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"startLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"startLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic dateModified;






@dynamic endDate;






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





@dynamic recordingDescription;






@dynamic remoteVideoURL;






@dynamic startDate;






@dynamic startLatitude;



- (double)startLatitudeValue {
	NSNumber *result = [self startLatitude];
	return [result doubleValue];
}

- (void)setStartLatitudeValue:(double)value_ {
	[self setStartLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveStartLatitudeValue {
	NSNumber *result = [self primitiveStartLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveStartLatitudeValue:(double)value_ {
	[self setPrimitiveStartLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic startLongitude;



- (double)startLongitudeValue {
	NSNumber *result = [self startLongitude];
	return [result doubleValue];
}

- (void)setStartLongitudeValue:(double)value_ {
	[self setStartLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveStartLongitudeValue {
	NSNumber *result = [self primitiveStartLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveStartLongitudeValue:(double)value_ {
	[self setPrimitiveStartLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic thumbnailURL;






@dynamic uuid;











@end
