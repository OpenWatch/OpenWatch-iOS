//
//  OWRecordingTag.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/3/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OWManagedRecording;

@interface OWRecordingTag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) OWManagedRecording *recording;

@end
