//
//  OWShareController.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/18/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWShareController : NSObject

+ (OWShareController *)sharedInstance;

@property (nonatomic, strong) NSManagedObjectID *recordingID;
@property (nonatomic, strong) UIViewController *viewController;

- (void) shareRecordingID:(NSManagedObjectID*)newRecordingID fromViewController:(UIViewController*)newViewController;
- (void) shareFromViewController:(UIViewController *)newViewController; // requires recordingID to be set

@end
