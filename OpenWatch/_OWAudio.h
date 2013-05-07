// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OWAudio.h instead.

#import <CoreData/CoreData.h>
#import "OWLocalMediaObject.h"

extern const struct OWAudioAttributes {
} OWAudioAttributes;

extern const struct OWAudioRelationships {
} OWAudioRelationships;

extern const struct OWAudioFetchedProperties {
} OWAudioFetchedProperties;



@interface OWAudioID : NSManagedObjectID {}
@end

@interface _OWAudio : OWLocalMediaObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OWAudioID*)objectID;






@end

@interface _OWAudio (CoreDataGeneratedAccessors)

@end

@interface _OWAudio (CoreDataGeneratedPrimitiveAccessors)


@end
