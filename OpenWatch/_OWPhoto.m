// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWPhoto.m instead.

#import "_OWPhoto.h"

const struct OWPhotoAttributes OWPhotoAttributes = {
};

const struct OWPhotoRelationships OWPhotoRelationships = {
};

const struct OWPhotoFetchedProperties OWPhotoFetchedProperties = {
};

@implementation OWPhotoID
@end

@implementation _OWPhoto

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWPhoto" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWPhoto";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWPhoto" inManagedObjectContext:moc_];
}

- (OWPhotoID*)objectID {
	return (OWPhotoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}









@end
