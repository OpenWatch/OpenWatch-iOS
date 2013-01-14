// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWRecordingSegment.m instead.

#import "_OWRecordingSegment.h"

const struct OWRecordingSegmentAttributes OWRecordingSegmentAttributes = {
	.fileName = @"fileName",
	.filePath = @"filePath",
	.uploadState = @"uploadState",
};

const struct OWRecordingSegmentRelationships OWRecordingSegmentRelationships = {
	.recording = @"recording",
};

const struct OWRecordingSegmentFetchedProperties OWRecordingSegmentFetchedProperties = {
};

@implementation OWRecordingSegmentID
@end

@implementation _OWRecordingSegment

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWRecordingSegment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWRecordingSegment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWRecordingSegment" inManagedObjectContext:moc_];
}

- (OWRecordingSegmentID*)objectID {
	return (OWRecordingSegmentID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"uploadStateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"uploadState"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic fileName;






@dynamic filePath;






@dynamic uploadState;



- (int16_t)uploadStateValue {
	NSNumber *result = [self uploadState];
	return [result shortValue];
}

- (void)setUploadStateValue:(int16_t)value_ {
	[self setUploadState:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveUploadStateValue {
	NSNumber *result = [self primitiveUploadState];
	return [result shortValue];
}

- (void)setPrimitiveUploadStateValue:(int16_t)value_ {
	[self setPrimitiveUploadState:[NSNumber numberWithShort:value_]];
}





@dynamic recording;

	






@end
