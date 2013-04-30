// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWLocalRecording.m instead.

#import "_OWLocalRecording.h"

const struct OWLocalRecordingAttributes OWLocalRecordingAttributes = {
	.hqFileUploadState = @"hqFileUploadState",
};

const struct OWLocalRecordingRelationships OWLocalRecordingRelationships = {
	.segments = @"segments",
};

const struct OWLocalRecordingFetchedProperties OWLocalRecordingFetchedProperties = {
};

@implementation OWLocalRecordingID
@end

@implementation _OWLocalRecording

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWLocalRecording" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWLocalRecording";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWLocalRecording" inManagedObjectContext:moc_];
}

- (OWLocalRecordingID*)objectID {
	return (OWLocalRecordingID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"hqFileUploadStateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hqFileUploadState"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic hqFileUploadState;



- (int16_t)hqFileUploadStateValue {
	NSNumber *result = [self hqFileUploadState];
	return [result shortValue];
}

- (void)setHqFileUploadStateValue:(int16_t)value_ {
	[self setHqFileUploadState:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveHqFileUploadStateValue {
	NSNumber *result = [self primitiveHqFileUploadState];
	return [result shortValue];
}

- (void)setPrimitiveHqFileUploadStateValue:(int16_t)value_ {
	[self setPrimitiveHqFileUploadState:[NSNumber numberWithShort:value_]];
}





@dynamic segments;

	
- (NSMutableSet*)segmentsSet {
	[self willAccessValueForKey:@"segments"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"segments"];
  
	[self didAccessValueForKey:@"segments"];
	return result;
}
	






@end
