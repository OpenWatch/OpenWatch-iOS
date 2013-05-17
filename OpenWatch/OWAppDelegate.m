//
//  OWAppDelegate.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWAppDelegate.h"
#import "OWUtilities.h"
#import "TestFlight.h"
#import "OWAPIKeys.h"
#import "OWFancyLoginViewController.h"
#import "OWSettingsController.h"
#import "OWAccountAPIClient.h"
#import "OWShareViewController.h"


@implementation OWAppDelegate
@synthesize navigationController, locationController, dashboardViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//#define TESTING 1
//#ifdef TESTING
    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
//#endif
//#ifndef DEBUG
    [TestFlight takeOff:TESTFLIGHT_APP_TOKEN];
//#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [OWUtilities stoneBackgroundPattern];
    self.locationController = [[OWLocationController alloc] init];
     
    //self.homeScreen = [[OWHomeScreenViewController alloc] init];
    self.dashboardViewController = [[OWDashboardViewController alloc] init];
    
    OWSettingsController *settingsController = [OWSettingsController sharedInstance];
    OWAccount *account = settingsController.account;
    UIViewController *vc = nil;
    if ([account isLoggedIn]) {
        vc = dashboardViewController;
    } else {
        OWFancyLoginViewController *fancy = [[OWFancyLoginViewController alloc] init];
        vc = fancy;
    }
    
    //vc = [[OWShareViewController alloc] init];
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{UITextAttributeTextColor : [UIColor blackColor], UITextAttributeTextShadowColor: [UIColor whiteColor], UITextAttributeFont: [UIFont systemFontOfSize:0]}];
    [[UINavigationBar appearance] setBackgroundImage:[OWUtilities navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[OWUtilities navigationBarColor]];
    self.window.rootViewController = navigationController;
    [MagicalRecord setupCoreDataStack];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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

@end
