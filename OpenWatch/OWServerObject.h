#import "_OWServerObject.h"

@interface OWServerObject : _OWServerObject {}
// Custom logic goes here.

- (void) saveMetadata;
- (NSMutableDictionary*) metadataDictionary;
- (void) loadMetadataFromDictionary:(NSDictionary*)metadataDictionary;

@end
