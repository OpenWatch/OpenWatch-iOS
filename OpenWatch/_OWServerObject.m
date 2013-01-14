// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWServerObject.m instead.

#import "_OWServerObject.h"

const struct OWServerObjectAttributes OWServerObjectAttributes = {
	.serverID = @"serverID",
};

const struct OWServerObjectRelationships OWServerObjectRelationships = {
};

const struct OWServerObjectFetchedProperties OWServerObjectFetchedProperties = {
};

@implementation OWServerObjectID
@end

@implementation _OWServerObject

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWServerObject" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWServerObject";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWServerObject" inManagedObjectContext:moc_];
}

- (OWServerObjectID*)objectID {
	return (OWServerObjectID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"serverIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"serverID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic serverID;



- (int32_t)serverIDValue {
	NSNumber *result = [self serverID];
	return [result intValue];
}

- (void)setServerIDValue:(int32_t)value_ {
	[self setServerID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveServerIDValue {
	NSNumber *result = [self primitiveServerID];
	return [result intValue];
}

- (void)setPrimitiveServerIDValue:(int32_t)value_ {
	[self setPrimitiveServerID:[NSNumber numberWithInt:value_]];
}










@end
