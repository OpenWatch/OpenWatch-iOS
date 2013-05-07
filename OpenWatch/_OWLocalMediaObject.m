// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWLocalMediaObject.m instead.

#import "_OWLocalMediaObject.h"

const struct OWLocalMediaObjectAttributes OWLocalMediaObjectAttributes = {
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
	
	if ([key isEqualToString:@"uploadedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"uploaded"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
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
