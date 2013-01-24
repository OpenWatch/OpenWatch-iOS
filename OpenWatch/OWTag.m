#import "OWTag.h"

#define kNameKey @"name"
#define kIDKey @"id"
#define kFeaturedKey @"featured"


@interface OWTag ()

// Private interface goes here.

@end


@implementation OWTag

// Custom logic goes here.

+ (OWTag*) tagWithDictionary:(NSDictionary*)dictionary {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSNumber *serverID = [dictionary objectForKey:kIDKey];
    NSString *name = [dictionary objectForKey:kNameKey];
    NSNumber *isFeatured = [dictionary objectForKey:kFeaturedKey];
    OWTag *tag = [OWTag MR_findFirstByAttribute:@"serverID" withValue:serverID inContext:context];
    if (!tag) {
        tag = [OWTag MR_findFirstByAttribute:kNameKey withValue:name inContext:context];
    }
    if (!tag) {
        tag = [OWTag MR_createEntity];
        tag.name = name;
        tag.serverID = serverID;
    }
    tag.isFeatured = isFeatured;
    [context obtainPermanentIDsForObjects:@[tag] error:nil];
    [context MR_saveToPersistentStoreAndWait];
    return tag;
}

@end
