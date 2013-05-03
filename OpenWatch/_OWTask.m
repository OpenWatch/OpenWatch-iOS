// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWTask.m instead.

#import "_OWTask.h"

const struct OWTaskAttributes OWTaskAttributes = {
	.body = @"body",
	.title = @"title",
};

const struct OWTaskRelationships OWTaskRelationships = {
	.investigation = @"investigation",
	.user = @"user",
};

const struct OWTaskFetchedProperties OWTaskFetchedProperties = {
};

@implementation OWTaskID
@end

@implementation _OWTask

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWTask" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWTask";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWTask" inManagedObjectContext:moc_];
}

- (OWTaskID*)objectID {
	return (OWTaskID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic body;






@dynamic title;






@dynamic investigation;

	
- (NSMutableSet*)investigationSet {
	[self willAccessValueForKey:@"investigation"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"investigation"];
  
	[self didAccessValueForKey:@"investigation"];
	return result;
}
	

@dynamic user;

	






@end
