// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWLocalMediaObject.m instead.

#import "_OWLocalMediaObject.h"

const struct OWLocalMediaObjectAttributes OWLocalMediaObjectAttributes = {
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
	

	return keyPaths;
}




@dynamic uuid;











@end
