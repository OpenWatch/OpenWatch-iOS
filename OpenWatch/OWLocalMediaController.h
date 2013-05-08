//
//  OWLocalMediaController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/7/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWUser.h"
#import "OWLocalMediaObject.h"

@interface OWLocalMediaController : NSObject

+ (NSArray*) allMediaObjectsForUser:(OWUser*)user;
+ (NSArray*) mediaObjectsForClass:(Class)class;

+ (void) scanDirectoryForChanges;
+ (void) scanDirectoryForUnsubmittedData;

+ (OWLocalMediaObject*) localMediaObjectForObjectID:(NSManagedObjectID*)objectID;
+ (void) removeLocalMediaObject:(NSManagedObjectID*)objectID;

@end
