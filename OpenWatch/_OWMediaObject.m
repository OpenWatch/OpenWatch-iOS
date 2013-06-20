// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWMediaObject.m instead.

#import "_OWMediaObject.h"

const struct OWMediaObjectAttributes OWMediaObjectAttributes = {
	.clicks = @"clicks",
	.firstPostedDate = @"firstPostedDate",
	.metroCode = @"metroCode",
	.modifiedDate = @"modifiedDate",
	.thumbnailURLString = @"thumbnailURLString",
	.title = @"title",
	.views = @"views",
};

const struct OWMediaObjectRelationships OWMediaObjectRelationships = {
	.tags = @"tags",
	.user = @"user",
};

const struct OWMediaObjectFetchedProperties OWMediaObjectFetchedProperties = {
};

@implementation OWMediaObjectID
@end

@implementation _OWMediaObject

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWMediaObject" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWMediaObject";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWMediaObject" inManagedObjectContext:moc_];
}

- (OWMediaObjectID*)objectID {
	return (OWMediaObjectID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"clicksValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"clicks"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"viewsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"views"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic clicks;



- (int32_t)clicksValue {
	NSNumber *result = [self clicks];
	return [result intValue];
}

- (void)setClicksValue:(int32_t)value_ {
	[self setClicks:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveClicksValue {
	NSNumber *result = [self primitiveClicks];
	return [result intValue];
}

- (void)setPrimitiveClicksValue:(int32_t)value_ {
	[self setPrimitiveClicks:[NSNumber numberWithInt:value_]];
}





@dynamic firstPostedDate;






@dynamic metroCode;






@dynamic modifiedDate;






@dynamic thumbnailURLString;






@dynamic title;






@dynamic views;



- (int32_t)viewsValue {
	NSNumber *result = [self views];
	return [result intValue];
}

- (void)setViewsValue:(int32_t)value_ {
	[self setViews:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveViewsValue {
	NSNumber *result = [self primitiveViews];
	return [result intValue];
}

- (void)setPrimitiveViewsValue:(int32_t)value_ {
	[self setPrimitiveViews:[NSNumber numberWithInt:value_]];
}





@dynamic tags;

	
- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];
  
	[self didAccessValueForKey:@"tags"];
	return result;
}
	

@dynamic user;

	






@end
