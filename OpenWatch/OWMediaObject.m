#import "OWMediaObject.h"
#import "OWTag.h"
#import "OWUser.h"
#import "OWUtilities.h"
#import "OWManagedRecording.h"
#import "OWMediaObjectTableViewCell.h"
#import "OWPhoto.h"
#import "OWInvestigation.h"
#import "OWAudio.h"
#import "OWLocalRecording.h"

@interface OWMediaObject ()

// Private interface goes here.

@end


@implementation OWMediaObject


+ (Class) cellClass {
    return [OWMediaObjectTableViewCell class];
}

+ (NSString*) cellIdentifier {
    return [NSString stringWithFormat:@"%@Cell", NSStringFromClass([self class])];
}

// Custom logic goes here.
- (NSMutableDictionary*) metadataDictionary {
    NSMutableDictionary *newMetadataDictionary = [NSMutableDictionary dictionary];
    if (self.title) {
        [newMetadataDictionary setObject:[self.title copy] forKey:kTitleKey];
    }
    if (self.firstPostedDate) {
        NSDateFormatter *dateFormatter = [OWUtilities utcDateFormatter];
        [newMetadataDictionary setObject:[dateFormatter stringFromDate:self.firstPostedDate] forKey:kFirstPostedKey];
    }
    if (self.serverID.intValue != 0) {
        [newMetadataDictionary setObject:self.serverID forKey:@"id"];
    }
    NSSet *tags = self.tags;
    NSMutableArray *tagsArray = [NSMutableArray arrayWithCapacity:tags.count];
    for (OWTag *tag in tags) {
        if ([tag.name isEqualToString:@""]) {
            continue;
        }
        [tagsArray addObject:tag.name];
    }
    [newMetadataDictionary setObject:tagsArray forKey:kTagsKey];
    
    return newMetadataDictionary;
}

- (void) saveMetadata {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreAndWait];
}

- (void) loadMetadataFromDictionary:(NSDictionary*)metadataDictionary {
    NSDateFormatter *dateFormatter = [OWUtilities utcDateFormatter];
    NSString *lastEdited = [metadataDictionary objectForKey:kLastEditedKey];
    if (lastEdited) {
        self.modifiedDate = [dateFormatter dateFromString:lastEdited];
    }
    NSString *firstPosted = [metadataDictionary objectForKey:kFirstPostedKey];
    if (firstPosted) {
        self.firstPostedDate = [dateFormatter dateFromString:firstPosted];
    }
    NSNumber *serverID = [metadataDictionary objectForKey:@"id"];
    if (serverID) {
        self.serverID = serverID;
    }    
    NSString *newTitle = [metadataDictionary objectForKey:kTitleKey];
    if (newTitle) {
        self.title = newTitle;
    }
    NSArray *tagsArray = [metadataDictionary objectForKey:kTagsKey];
    if (tagsArray) {
        NSMutableSet *tags = [NSMutableSet set];
        for (NSDictionary *tagDictionary in tagsArray) {
            OWTag *tag = [OWTag tagWithDictionary:tagDictionary];
            [tags addObject:tag];
        }
        self.tags = tags;
    }
    NSDictionary *userDictionary = [metadataDictionary objectForKey:kUserKey];
    if (userDictionary) {
        NSNumber *userID = [userDictionary objectForKey:kIDKey];
        NSString *username = [userDictionary objectForKey:kUsernameKey];
        NSString *thumbnail = [userDictionary objectForKey:@"thumbnail_url"];
        OWUser *user = [OWUser MR_findFirstByAttribute:@"serverID" withValue:userID];
        if (!user) {
            user = [OWUser MR_createEntity];
            user.serverID = userID;
        }
        user.username = username;
        user.thumbnailURLString = thumbnail;
        self.user = user;
    }
    NSNumber *views = [metadataDictionary objectForKey:@"views"];
    if (views) {
        self.views = views;
    }
    NSNumber *clicks = [metadataDictionary objectForKey:@"clicks"];
    if (clicks) {
        self.clicks = clicks;
    }
    NSString *thumbnailURLString = [[metadataDictionary objectForKey:@"thumbnail_url"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (thumbnailURLString) {
        self.thumbnailURLString = thumbnailURLString;
    }
}

// stub methods, implemented in subclasses
- (NSString*) type { return nil; }
- (NSURL*) thumbnailURL {
    return [NSURL URLWithString:self.thumbnailURLString];
}

- (NSString*) apiLetter {
    NSString *type = @"";
    if ([self isKindOfClass:[OWPhoto class]]) {
        type = @"p";
    } else if ([self isKindOfClass:[OWInvestigation class]]) {
        type = @"i";
    } else if ([self isKindOfClass:[OWLocalRecording class]] || [self isKindOfClass:[OWManagedRecording class]]) {
        type = @"v";
    } else if ([self isKindOfClass:[OWAudio class]]){
        type = @"a";
    } else {
        return nil;
    }
    return type;
}

- (NSString*) relativeShareURLPath {
    if (self.serverIDValue == 0) {
        return nil;
    }
    NSString *type = [self apiLetter];
    return [NSString stringWithFormat:@"/%@/%d", type, self.serverIDValue];
}

- (NSString*) absoluteShareURLString {
    NSString *relative = [self relativeShareURLPath];
    NSString *websiteBaseURL = [OWUtilities websiteBaseURLString];
    if (!relative) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@%@", websiteBaseURL, relative];
}

- (NSURL*) shareURL {
    NSString *abs = [self absoluteShareURLString];
    if (!abs) {
        return nil;
    }
    return [NSURL URLWithString:abs];
}

- (NSString*) baseAPIPath {
    NSString *type = [self apiLetter];
    return [NSString stringWithFormat:@"/api/%@/", type];
}

- (NSString*) fullAPIPath {
    NSString *type = [self apiLetter];
    return [NSString stringWithFormat:@"/api/%@/%d/", type, self.serverID.intValue];
}

@end
