//
//  OWSHKConfigurator.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/18/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWSHKConfigurator.h"

@implementation OWSHKConfigurator

- (NSString*)appName {
	return @"OpenWatch";
}

- (NSString*)appURL {
	return @"http://openwatch.net";
}

- (NSString*)facebookAppId {
	return @"297496017037529";
}

- (NSArray*)defaultFavoriteURLSharers {
    return [NSArray arrayWithObjects:@"SHKTwitter",@"SHKFacebook", @"SHKMail", nil];
}

@end
