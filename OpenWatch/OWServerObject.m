#import "OWServerObject.h"


@interface OWServerObject ()

// Private interface goes here.

@end


@implementation OWServerObject

- (void) loadMetadataFromDictionary:(NSDictionary*)metadataDictionary {
    NSNumber *serverID = [metadataDictionary objectForKey:@"id"];
    if (serverID) {
        self.serverID = serverID;
    }
}


- (NSMutableDictionary*) metadataDictionary {
    NSMutableDictionary *newMetadataDictionary = [NSMutableDictionary dictionary];
    if (self.serverID.intValue != 0) {
        [newMetadataDictionary setObject:self.serverID forKey:@"id"];
    }
    return newMetadataDictionary;
}

- (void) saveMetadata {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreAndWait];
}


@end
