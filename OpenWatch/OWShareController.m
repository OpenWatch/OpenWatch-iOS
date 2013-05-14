//
//  OWShareController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 5/13/13.
//  Copyright (c) 2013 OpenWatch FPC. All rights reserved.
//

#import "OWShareController.h"
#import "TUSafariActivity.h"

@implementation OWShareController

+ (void) shareURL:(NSURL*)url title:(NSString*)title fromViewController:(UIViewController*)viewController {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[title, url] applicationActivities:nil];
    
    [viewController presentViewController:activityViewController animated:YES completion:nil];
}

+ (void) shareMediaObject:(OWMediaObject*)mediaObject fromViewController:(UIViewController*)viewController {
    TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:2];
    if (mediaObject.shareURL) {
        [items addObject:mediaObject.shareURL];
        if (mediaObject.title) {
            [items addObject:mediaObject.title];
        }
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[safariActivity]];
        
        UIActivityViewControllerCompletionHandler completionHandler = ^(NSString *activityType, BOOL completed) {
            NSLog(@"activity: %@", activityType);
        };
        
        activityViewController.completionHandler = completionHandler;
        
        [viewController presentViewController:activityViewController animated:YES completion:nil];
    }
}

@end
