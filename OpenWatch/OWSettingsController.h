//
//  OWSettingsController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/13/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWAccount.h"

@interface OWSettingsController : NSObject

@property (nonatomic, retain) OWAccount *account;

+ (OWSettingsController*) sharedInstance;

@end
