//
//  OWAppDelegate.m
//  OpenWatch
//
//  Created by Christopher Ballinger on 11/12/12.
//  Copyright (c) 2012 OpenWatch FPC. All rights reserved.
//

#import "OWAppDelegate.h"
#import "OWSettingsViewController.h"
#import "OWLoginViewController.h"
#import "OWSettingsController.h"

@implementation OWAppDelegate
@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.tabBarController = [[UITabBarController alloc] init];
    OWSettingsViewController *settingsViewController = [[OWSettingsViewController alloc] init];
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    self.tabBarController.viewControllers = @[ settingsNavController];
    self.window.rootViewController = self.tabBarController;
    
    [self.window makeKeyAndVisible];
    [self performSelector:@selector(checkAccount) withObject:nil afterDelay:0.1f];
    return YES;
}

- (void) checkAccount {
    OWLoginViewController *loginViewController = [[OWLoginViewController alloc] init];
    UINavigationController *loginNavController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    OWSettingsController *settingsController = [OWSettingsController sharedInstance];
    if (!settingsController.account.email) {
        [self.tabBarController presentViewController:loginNavController animated:YES completion:^{
            
        }];
    }
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
}

@end
