//
//  OWAppDelegate.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWAppDelegate.h"
#import "OWUtilities.h"
#import "OWAPIKeys.h"
#import "OWFancyLoginViewController.h"
#import "OWSettingsController.h"
#import "OWAccountAPIClient.h"
#import "OWMissionListViewController.h"
#import "OWMissionViewController.h"
#import "OWMission.h"
#import "PKRevealController.h"
#import "Crittercism.h"

@implementation OWAppDelegate
@synthesize locationController, dashboardViewController, backgroundTask, backgroundTimer, allowRotation, creationController, revealController, feedViewController, navigationController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crittercism enableWithAppID:CRITTERCISM_APP_ID];
    [MagicalRecord setupAutoMigratingCoreDataStack];

    self.allowRotation = NO;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [OWUtilities stoneBackgroundPattern];
    self.locationController = [[OWLocationController alloc] init];
     
    self.dashboardViewController = [[[self dashboardClass] alloc] init];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerWillEnterFullscreenNotification:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerWillExitFullscreenNotification:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{UITextAttributeTextColor : [UIColor blackColor], UITextAttributeTextShadowColor: [UIColor whiteColor], UITextAttributeFont: [UIFont systemFontOfSize:0]}];
    [[UINavigationBar appearance] setBackgroundImage:[OWUtilities navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[OWUtilities navigationBarColor]];
    
    self.feedViewController = [[[self feedViewClass] alloc] init];
    
    OWSettingsController *settingsController = [OWSettingsController sharedInstance];
    OWAccount *account = settingsController.account;
    self.navigationController = [[UINavigationController alloc] init];
    BOOL loggedIn = NO;
    if ([account isLoggedIn]) {
        navigationController.viewControllers = @[feedViewController];
        loggedIn = YES;
    } else {
        OWFancyLoginViewController *fancy = [[[self loginControllerClass] alloc] init];
        navigationController.viewControllers = @[fancy];
    }
    
    self.revealController = [PKRevealController revealControllerWithFrontViewController:navigationController leftViewController:dashboardViewController options:nil];
    
    if (!loggedIn) {
        self.revealController.recognizesPanningOnFrontView = NO;
    }
    
    self.window.rootViewController = revealController;
    
    // for testing views directly
    //self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[OWLocalMediaEditViewController alloc] init]];
    
    self.creationController = [[[self mediaCreationClass] alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

- (Class) mediaCreationClass {
    return [OWMediaCreationController class];
}

- (Class) feedViewClass {
    return [OWFeedViewController class];
}

- (Class) loginControllerClass {
    return [OWFancyLoginViewController class];
}

- (Class) dashboardClass {
    return [OWDashboardViewController class];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"Application entered background state.");
    //NSAssert(self.backgroundTask == UIBackgroundTaskInvalid, nil);
    
    self.backgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Background task expired");
            if (self.backgroundTimer)
            {
                [self.backgroundTimer invalidate];
                self.backgroundTimer = nil;
            }
            [application endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerUpdate:) userInfo:nil repeats:YES];
    });
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    
    NSLog(@"Application became active");
    
    if (self.backgroundTimer)
    {
        [self.backgroundTimer invalidate];
        self.backgroundTimer = nil;
    }
    if (self.backgroundTask != UIBackgroundTaskInvalid)
    {
        [application endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

- (BOOL)handleOpenURL:(NSURL*)url
{
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [self handleOpenURL:url];
}

- (BOOL)openURL:(NSURL*)url
{
    BrowserViewController *bvc = [[BrowserViewController alloc] initWithUrls:url];
    [self.navigationController pushViewController:bvc animated:YES];
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	[[OWAccountAPIClient sharedClient] updateUserPushToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get push token, error: %@", error);
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"Received local notification: %@", notification.userInfo);
    
    OWMissionListViewController *missionList = [[OWMissionListViewController alloc] init];
    OWMissionViewController *missionView = [[OWMissionViewController alloc] init];
    OWMission *mission = [OWMission MR_findFirstByAttribute:@"serverID" withValue:@(4)];
    
    
    missionView.mediaObjectID = mission.objectID;
    [self.navigationController setViewControllers:@[dashboardViewController, missionList, missionView]];
}

- (void) timerUpdate:(NSTimer*)timer {

    UIApplication *application = [UIApplication sharedApplication];
    /*
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif) {
        localNotif.alertBody = @"You have been selected for a special mission.";
        localNotif.alertAction = @"Accept";
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        [application presentLocalNotificationNow:localNotif];
    }
    */
    
    //NSLog(@"Timer update, background time left: %f", application.backgroundTimeRemaining);
    
    if ([application backgroundTimeRemaining] < 10)
    {
        NSLog(@"10 seconds of background time left... shutting down.");
        // Clean up here
        [self.backgroundTimer invalidate];
        self.backgroundTimer = nil;
        
        [application endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}


- (void) moviePlayerWillEnterFullscreenNotification:(NSNotification*)notification {
    self.allowRotation = YES;
}

- (void) moviePlayerWillExitFullscreenNotification:(NSNotification*)notification {
    self.allowRotation = NO;
}

-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end
