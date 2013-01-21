// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWTag.m instead.

#import "_OWTag.h"

const struct OWTagAttributes OWTagAttributes = {
	.isFeatured = @"isFeatured",
	.name = @"name",
};

const struct OWTagRelationships OWTagRelationships = {
	.objects = @"objects",
	.users = @"users",
};

const struct OWTagFetchedProperties OWTagFetchedProperties = {
};

@implementation OWTagID
@end

@implementation _OWTag

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWTag" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWTag";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWTag" inManagedObjectContext:moc_];
}

- (OWTagID*)objectID {
	return (OWTagID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isFeaturedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isFeatured"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic isFeatured;



- (BOOL)isFeaturedValue {
	NSNumber *result = [self isFeatured];
	return [result boolValue];
}

- (void)setIsFeaturedValue:(BOOL)value_ {
	[self setIsFeatured:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsFeaturedValue {
	NSNumber *result = [self primitiveIsFeatured];
	return [result boolValue];
}

- (void)setPrimitiveIsFeaturedValue:(BOOL)value_ {
	[self setPrimitiveIsFeatured:[NSNumber numberWithBool:value_]];
}





@dynamic name;






@dynamic objects;

	
- (NSMutableSet*)objectsSet {
	[self willAccessValueForKey:@"objects"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"objects"];
  
	[self didAccessValueForKey:@"objects"];
	return result;
}
	

@dynamic users;

	
- (NSMutableSet*)usersSet {
	[self willAccessValueForKey:@"users"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"users"];
  
	[self didAccessValueForKey:@"users"];
	return result;
}
	






@end
