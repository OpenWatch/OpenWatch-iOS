#import "_OWMediaObject.h"

#define kUUIDKey @"uuid"
#define kTitleKey @"title"
#define kTagsKey @"tags"
#define kUserKey @"user"
#define kIDKey @"id"
#define kUsernameKey @"username"
#define kFirstPostedKey @"first_posted"

@interface OWMediaObject : _OWMediaObject {}
// Custom logic goes here.

- (void) saveMetadata;
- (NSMutableDictionary*) metadataDictionary;
- (void) loadMetadataFromDictionary:(NSDictionary*)metadataDictionary;
- (NSURL*) urlForWeb;
- (NSString*) type;
- (NSURL*) thumbnailURL;

@end
