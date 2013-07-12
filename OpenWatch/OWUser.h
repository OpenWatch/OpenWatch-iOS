//
//  OWUser.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "_OWUser.h"

@class OWManagedRecording;

@interface OWUser : _OWUser

- (NSURL*) thumbnailURL;
- (NSString*) displayName;

@end
