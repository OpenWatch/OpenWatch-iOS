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

- (NSString*) type;
- (NSURL*) thumbnailURL;

- (NSString*) baseAPIPath;
- (NSString*) fullAPIPath;
- (NSURL*) shareURL;

+ (Class) cellClass;
+ (NSString*) cellIdentifier;

- (UIImage*) placeholderThumbnailImage;
- (UIImage*) mediaTypeImage;

- (NSString*) titleOrHumanizedDateString;

@end
