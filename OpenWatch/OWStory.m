#import "OWStory.h"
#import "OWUtilities.h"

@interface OWStory ()

// Private interface goes here.

@end


@implementation OWStory

- (void) loadMetadataFromDictionary:(NSDictionary*)metadataDictionary {
    [super loadMetadataFromDictionary:metadataDictionary];
    NSString *blurb = [metadataDictionary objectForKey:kBlurbKey];
    if (blurb) {
        self.blurb = blurb;
    }
    NSString *body = [metadataDictionary objectForKey:kBodyKey];
    if (body) {
        self.body = body;
    }
    NSString *slug = [metadataDictionary objectForKey:kSlugKey];
    if (slug) {
        self.slug = slug;
    }
}

- (NSMutableDictionary*) metadataDictionary {
    NSMutableDictionary *newMetadataDictionary = [super metadataDictionary];
    NSString *blurb = self.blurb;
    if (blurb) {
        [newMetadataDictionary setObject:blurb forKey:kBlurbKey];
    }
    NSString *body = self.body;
    if (body) {
        [newMetadataDictionary setObject:body forKey:kBodyKey];
    }
    NSString *slug = self.slug;
    if (slug) {
        [newMetadataDictionary setObject:slug forKey:kSlugKey];
    }
    return newMetadataDictionary;
}

- (NSURL*) urlForWeb {
    NSString *baseURLString = [OWUtilities apiBaseURLString];
    NSString *recordingURLString = [baseURLString stringByAppendingFormat:@"s/%d/%@", [self.serverID intValue], self.slug];
    return [NSURL URLWithString:recordingURLString];
}

- (NSString*) type {
    return @"story";
}

@end
