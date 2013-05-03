//
//  OWInvestigation.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 4/30/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWInvestigation.h"

#define kBlurbKey @"blurb"
#define kBodyKey @"body"
#define kHtmlKey @"html"
#define kLogoKey @"logo"
#define kBigLogoKey @"big_logo"
#define kQuestionsKey @"questions"


@implementation OWInvestigation

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
    NSString *logo = [metadataDictionary objectForKey:kLogoKey];
    if (logo) {
        self.logo = logo;
    }
    NSString *big_logo = [metadataDictionary objectForKey:kBigLogoKey];
    if (big_logo) {
        self.bigLogo = big_logo;
    }
    NSString *questions = [metadataDictionary objectForKey:kQuestionsKey];
    if (questions) {
        self.questions = questions;
    }
    NSString *html = [metadataDictionary objectForKey:kHtmlKey];
    if (html) {
        self.html = html;
    }
}

- (NSString*) type {
    return @"investigation";
}


@end
