// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWUser.m instead.

#import "_OWUser.h"

const struct OWUserAttributes OWUserAttributes = {
	.thumbnailURLString = @"thumbnailURLString",
	.username = @"username",
};

const struct OWUserRelationships OWUserRelationships = {
	.objects = @"objects",
	.tags = @"tags",
	.tasks = @"tasks",
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
	

	return keyPaths;
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
	

@dynamic tasks;

	
- (NSMutableSet*)tasksSet {
	[self willAccessValueForKey:@"tasks"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tasks"];
  
	[self didAccessValueForKey:@"tasks"];
	return result;
}
	






@end
