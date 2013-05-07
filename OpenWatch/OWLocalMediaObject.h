//
//  OWLocalMediaObject.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/7/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "_OWLocalMediaObject.h"


@interface OWLocalMediaObject : _OWLocalMediaObject

+ (NSString*) mediaDirectoryPath;
+ (NSString*) mediaDirectoryPathForMediaType:(NSString*)mediaType;
+ (NSString*) pathForUUID:(NSString*)uuid;

- (NSString*) dataDirectory;
- (NSString*) localMediaPath;
- (NSURL*) localMediaURL;

+ (NSString *)newUUID;

+ (OWLocalMediaObject*) localMediaObjectWithUUID:(NSString*)uuid;
+ (OWLocalMediaObject*) localMediaObject;

@end
