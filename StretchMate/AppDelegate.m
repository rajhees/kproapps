//
//  AppDelegate.m
//  StretchMate
//
//  Created by James Eunson on 20/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "AppDelegate.h"
#import "TestFlight.h"
#import "StretchMate.h"
#import "MMDrawerVisualState.h"
#import <BugSense-iOS/BugSenseController.h>
#import "ExercisesViewController.h"
#import "ExersiteSession.h"

#define kTestFlightTestAPIKey @"0c0335e8-0790-4f2f-9fa5-b917aa5a963e"
#define kTestFlightProductionAPIKey @""
#define kBugsenseAPIKey @"2fee2632"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

//    NSLog(@"%@", [[NSBundle mainBundle] resourcePath]);

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        // Orange bar style
        [[UINavigationBar appearance] setTintColor:kTintColour];
        
        // Set charcoal appearance for both
        [[UITabBar appearance] setTintColor:RGBCOLOR(51, 51, 51)];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        
    } else {
        
        [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
        [[UINavigationBar appearance] setTintColor:RGBCOLOR(216, 116, 36)];
        
        self.navController.navigationBar.translucent = YES;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    self.drawerController = (MMDrawerController *)self.window.rootViewController;
    
    [_drawerController setMaximumLeftDrawerWidth:kSidebarWidth];
    [_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [_drawerController setDrawerVisualStateBlock:[MMDrawerVisualState parallaxVisualStateBlockWithParallaxFactor:2.0]];
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) { // iOS7 only
        [_drawerController setShowsShadow:NO];
    }
    
    if([[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location == NSNotFound) {
//        [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
        [TestFlight takeOff:kTestFlightTestAPIKey];
        [BugSenseController sharedControllerWithBugSenseAPIKey:kBugsenseAPIKey];
    }
    
    if([[ExersiteSession currentSession] isUserLoggedIn]) {
        
        LoginViewController *viewController = (LoginViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"LoginViewController"];
        viewController.delegate = self;
        
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        self.window.rootViewController = navController;
        
        viewController.shouldAuthenticateUsingSavedCredentials = YES;
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; // Reset, if non-zero
    
    return YES;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

//    NSLog(@"deviceToken: %@", [NSString stringWithFormat:@"%@",deviceToken]);
    NSString * deviceTokenString = [deviceToken description];
    
	deviceTokenString = [deviceTokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[AppConfig sharedConfig] setObject:deviceTokenString forKey:kPushNotificationDeviceToken];
    
    [self attemptPushRegistration];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
//    NSLog(@"%@", str);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    NSLog(@"didReceiveRemoteNotification: %@", userInfo);
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:userInfo[@"aps"][@"alert"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
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
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; // Reset, if non-zero
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - LoginViewControllerDelegate Methods
- (void)loginViewControllerDidLogin:(LoginViewController*)controller {
    [UIView transitionWithView:self.window duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{ self.window.rootViewController = _drawerController; } completion:nil];
}

- (void)loginViewControllerLoginDidFail:(LoginViewController*)controller {
    [[ExersiteSession currentSession] destroySession];
    
    [UIView transitionWithView:self.window duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{ self.window.rootViewController = _drawerController; } completion:nil];
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your account credentials were not accepted by the server and you have been logged out. You can attempt to log in again by using the button at the top of the sidebar." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

#pragma mark - Push Notifications
- (void)attemptPushRegistration {
    
    if([[AppConfig sharedConfig] pushNotificationDeviceTokenRecorded]) {
        return;
    }
    
    if([[ExersiteSession currentSession] isUserLoggedIn]) {
        ExersiteHTTPClient * client = [[ExersiteHTTPClient alloc] init];
        NSString * deviceToken = [[AppConfig sharedConfig] pushNotificationDeviceToken];
        
        if(!deviceToken) { // Simulator and worst case scenario on phones
            return;
        }
        
        [client attemptSetDevicePushNotificationToken:deviceToken completion:^(NSDictionary *result) {
            if([[result allKeys] count] > 0 && [[result allKeys] containsObject:@"success"] && [result[@"success"] isEqualToString:@"true"]) {
                [[AppConfig sharedConfig] setBool:YES forKey:kPushNotificationDeviceTokenRecorded];
            }
        }];
    }
    
}

- (void)saveUserContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.userManagedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
        }
    }
}

- (void)saveContext {
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StretchMate" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL * readOnlyStoreURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Exersite" ofType:@"sqlite" inDirectory:nil]];
    NSError * error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:readOnlyStoreURL options:@{NSReadOnlyPersistentStoreOption: @(YES)} error:&error]) {
        NSLog(@"addPersistentStoreWithType ReadOnly error: %@", [error localizedDescription]);
    }

//    NSURL * applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//    NSURL * storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"Exersite.sqlite"];
//    NSError *error = nil;
//
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//
//        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occurred in initialising the user database. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alertView show];
//    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - User Core Data stack
- (NSManagedObjectModel*)userManagedObjectModel {
    
    if (_userManagedObjectModel != nil)
    {
        return _userManagedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StretchMateUser" withExtension:@"momd"];
    _userManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _userManagedObjectModel;
}

- (NSManagedObjectContext *)userManagedObjectContext
{
    if (_userManagedObjectContext != nil)
    {
        return _userManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self userPersistentStoreCoordinator];
    if (coordinator != nil)
    {
        _userManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [_userManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _userManagedObjectContext;
}

- (NSPersistentStoreCoordinator *)userPersistentStoreCoordinator
{
    if (_userPersistentStoreCoordinator != nil)
    {
        return _userPersistentStoreCoordinator;
    }
    
    NSURL * applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL * storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"ExersiteUser.sqlite"];
    NSError *error = nil;
    
    
    NSDictionary * options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption: @YES };
    
    _userPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self userManagedObjectModel]];
    if (![_userPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occurred in initialising the user database. Please delete and reinstall this app from the store." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    return _userPersistentStoreCoordinator;
}

@end
