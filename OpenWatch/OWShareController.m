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
#import "OWStory.h"

@implementation OWShareController
@synthesize mediaObjectID, viewController;

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

- (void) shareMediaObjectID:(NSManagedObjectID*)newMediaObjectID fromViewController:(UIViewController*)newViewController {
    mediaObjectID = newMediaObjectID;
    [self shareFromViewController:newViewController];
}

- (void) shareFromViewController:(UIViewController*)newViewController {
    viewController = newViewController;
    if (!mediaObjectID) {
        return;
    }
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context objectWithID:self.mediaObjectID];
    
    if ([mediaObject.serverID intValue] != 0) {
        [self share];
    } else {
        if ([mediaObject isKindOfClass:[OWManagedRecording class]]) {
            OWManagedRecording *recording = (OWManagedRecording*)mediaObject;
            [[OWAccountAPIClient sharedClient] getRecordingWithUUID:recording.uuid success:^(NSManagedObjectID *recordingObjectID) {
                [self share];
            } failure:^(NSString *reason) {
                NSLog(@"Failed to GET recording: %@", reason);
            }];
        } else if ([mediaObject isKindOfClass:[OWStory class]]) {
            [[OWAccountAPIClient sharedClient] getStoryWithObjectID:self.mediaObjectID success:^(NSManagedObjectID *recordingObjectID) {
                [self share];
            } failure:^(NSString *reason) {
                NSLog(@"Failed to GET recording: %@", reason);
            }];
        }
    }
}

- (void) share {
    [TestFlight passCheckpoint:SHARE_CHECKPOINT];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    OWMediaObject *mediaObject = (OWMediaObject*)[context objectWithID:self.mediaObjectID];
    // Create the item to share (in this example, a url)
    NSURL *url = [mediaObject urlForWeb];
    NSString *title = [NSString stringWithFormat:@"%@ - %@", OPENWATCH_STRING, mediaObject.title];
    SHKItem *item = [SHKItem URL:url title:title contentType:SHKURLContentTypeWebpage];
    
    [TestFlight passCheckpoint:SHARE_URL_CHECKPOINT(url.absoluteString)];
    
    // Get the ShareKit action sheet
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
    // ShareKit detects top view controller (the one intended to present ShareKit UI) automatically,
    // but sometimes it may not find one. To be safe, set it explicitly
    [SHK setRootViewController:viewController];
    
    // Display the action sheet
    [actionSheet showFromToolbar:viewController.navigationController.toolbar];
    
    self.viewController = nil;
    self.mediaObjectID = nil;
}

@end
