// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWAudio.m instead.

#import "_OWAudio.h"

const struct OWAudioAttributes OWAudioAttributes = {
};

const struct OWAudioRelationships OWAudioRelationships = {
};

const struct OWAudioFetchedProperties OWAudioFetchedProperties = {
};

@implementation OWAudioID
@end

@implementation _OWAudio

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OWAudio" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OWAudio";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OWAudio" inManagedObjectContext:moc_];
}

- (OWAudioID*)objectID {
	return (OWAudioID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}









@end
