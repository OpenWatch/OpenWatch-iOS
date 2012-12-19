//
//  OWShareController.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/18/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWShareController.h"
#import "OWRecordingController.h"
#import "OWStrings.h"
#import "SHK.h"
#import "OWAccountAPIClient.h"

@implementation OWShareController
@synthesize recordingID, viewController;

+ (OWShareController *)sharedInstance {
    static OWShareController *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[OWShareController alloc] init];
    });
    return _sharedClient;
}

- (id) init {
    if (self = [super init]) {
    }
    return self;
}

- (void) shareRecordingID:(NSManagedObjectID *)newRecordingID fromViewController:(UIViewController *)newViewController {
    recordingID = newRecordingID;
    [self shareFromViewController:newViewController];
}

- (void) shareFromViewController:(UIViewController*)newViewController {
    viewController = newViewController;
    if (!recordingID) {
        return;
    }
    OWManagedRecording *recording = [OWRecordingController recordingForObjectID:recordingID];
    
    if ([recording.serverID intValue] != 0) {
        [self share];
    } else {
        [[OWAccountAPIClient sharedClient] getRecordingWithUUID:recording.uuid success:^(NSManagedObjectID *recordingObjectID) {
            [self share];
        } failure:^(NSString *reason) {
            NSLog(@"Failed to GET recording: %@", reason);
        }];
    }

}

- (void) share {
    OWManagedRecording *recording = [OWRecordingController recordingForObjectID:recordingID];
    // Create the item to share (in this example, a url)
    NSURL *url = [recording urlForRemoteRecording];
    NSString *title = [NSString stringWithFormat:@"%@ - %@", OPENWATCH_STRING, recording.title];
    SHKItem *item = [SHKItem URL:url title:title contentType:SHKURLContentTypeWebpage];
    
    // Get the ShareKit action sheet
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
    // ShareKit detects top view controller (the one intended to present ShareKit UI) automatically,
    // but sometimes it may not find one. To be safe, set it explicitly
    [SHK setRootViewController:viewController];
    
    // Display the action sheet
    [actionSheet showFromToolbar:viewController.navigationController.toolbar];
    
    self.viewController = nil;
    self.recordingID = nil;
}

@end
