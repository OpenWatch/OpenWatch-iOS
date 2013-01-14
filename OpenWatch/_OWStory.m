// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWStory.m instead.

#import "_OWStory.h"

const struct OWStoryAttributes OWStoryAttributes = {
	.blurb = @"blurb",
	.body = @"body",
	.slug = @"slug",
};

const struct OWStoryRelationships OWStoryRelationships = {
};

const struct OWStoryFetchedProperties OWStoryFetchedProperties = {
};

@implementation OWStoryID
@end

@implementation _OWStory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWStory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWStory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWStory" inManagedObjectContext:moc_];
}

- (OWStoryID*)objectID {
	return (OWStoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic blurb;






@dynamic body;






@dynamic slug;











@end
