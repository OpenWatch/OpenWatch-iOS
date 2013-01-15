//
//  OWCheckpoints.h
//  OpenWatch
//
//  Created by Christopher Ballinger on 12/19/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#define LOGIN_CHECKPOINT @"User Logged In"
#define NEW_ACCOUNT_CHECKPOINT @"New Account Created"
#define RECORDING_STARTED_CHECKPOINT @"New Recording Started"
#define WATCH_CHECKPOINT @"Watch Screen"
#define VIEW_FEED_CHECKPOINT(feedName) [NSString stringWithFormat:@"View Feed: %@", feedName]
#define EDIT_METADATA_CHECKPOINT @"Edit Metadata"
#define WELCOME_CHECKPOINT @"Welcome Screen"
#define HOME_CHECKPOINT @"Home Screen"
#define VIEW_RECORDING_CHECKPOINT @"View Recording Screen"
#define VIEW_RECORDING_ID_CHECKPOINT(ID) [NSString stringWithFormat:@"View Recording: %d", ID]
#define SHARE_CHECKPOINT @"Share"
#define SHARE_URL_CHECKPOINT(URL) [NSString stringWithFormat:@"Share URL: %@", URL]
#define VIEW_SETTINGS_CHECKPOINT @"View Settings"
#define VIEW_LOCAL_RECORDINGS @"Local Recordings Screen"
#define EDIT_TAGS_CHECKPOINT @"Edit Tags Screen"
