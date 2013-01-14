// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWUser.m instead.

#import "_OWUser.h"

const struct OWUserAttributes OWUserAttributes = {
	.csrfToken = @"csrfToken",
	.serverID = @"serverID",
	.thumbnailURLString = @"thumbnailURLString",
	.username = @"username",
};

const struct OWUserRelationships OWUserRelationships = {
	.objects = @"objects",
	.tags = @"tags",
};

const struct OWUserFetchedProperties OWUserFetchedProperties = {
};

@implementation OWUserID
@end

@implementation _OWUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWUser" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWUser";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWUser" inManagedObjectContext:moc_];
}

- (OWUserID*)objectID {
	return (OWUserID*)[super objectID];
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




@dynamic csrfToken;






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





@dynamic thumbnailURLString;






@dynamic username;






@dynamic objects;

	
- (NSMutableSet*)objectsSet {
	[self willAccessValueForKey:@"objects"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"objects"];
  
	[self didAccessValueForKey:@"objects"];
	return result;
}
	

@dynamic tags;

	
- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];
  
	[self didAccessValueForKey:@"tags"];
	return result;
}
	






@end
