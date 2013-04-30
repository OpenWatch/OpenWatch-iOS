// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWInvestigation.m instead.

#import "_OWInvestigation.h"

const struct OWInvestigationAttributes OWInvestigationAttributes = {
};

const struct OWInvestigationRelationships OWInvestigationRelationships = {
};

const struct OWInvestigationFetchedProperties OWInvestigationFetchedProperties = {
};

@implementation OWInvestigationID
@end

@implementation _OWInvestigation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWInvestigation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWInvestigation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWInvestigation" inManagedObjectContext:moc_];
}

- (OWInvestigationID*)objectID {
	return (OWInvestigationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}









@end
