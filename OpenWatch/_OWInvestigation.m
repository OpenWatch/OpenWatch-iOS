// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWInvestigation.m instead.

#import "_OWInvestigation.h"

const struct OWInvestigationAttributes OWInvestigationAttributes = {
	.bigLogo = @"bigLogo",
	.blurb = @"blurb",
	.body = @"body",
	.html = @"html",
	.logo = @"logo",
	.questions = @"questions",
};

const struct OWInvestigationRelationships OWInvestigationRelationships = {
	.tasks = @"tasks",
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




@dynamic bigLogo;






@dynamic blurb;






@dynamic body;






@dynamic html;






@dynamic logo;






@dynamic questions;






@dynamic tasks;

	
- (NSMutableSet*)tasksSet {
	[self willAccessValueForKey:@"tasks"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tasks"];
  
	[self didAccessValueForKey:@"tasks"];
	return result;
}
	






@end
