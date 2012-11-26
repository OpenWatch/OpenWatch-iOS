//
//  OWMapAnnotation.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/26/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWMapAnnotation.h"

@implementation OWMapAnnotation
@synthesize coordinate, title, subtitle;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)newTitle subtitle:(NSString *)newSubtitle {
    if (self = [super init]) {
        self.coordinate = coord;
        self.title = newTitle;
        self.subtitle = newSubtitle;
    }
    return self;
}


@end
