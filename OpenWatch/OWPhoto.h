//
//  OWPhoto.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/7/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "_OWPhoto.h"


@interface OWPhoto : _OWPhoto

@property (nonatomic, strong) NSNumber *uploaded;

+ (OWPhoto*) photoWithImage:(UIImage*)image;
+ (OWPhoto*) photoWithUUID:(NSString*)uuid;
+ (OWPhoto*) photo;


@end
