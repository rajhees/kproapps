//
//  AppDelegate.h
//  StretchMate
//
//  Created by James Eunson on 20/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMTabBarController.h"
#import "MMDrawerController.h"
#import "LoginViewController.h"

#define kSidebarWidth 260.0f

@interface AppDelegate : UIResponder <UIApplicationDelegate, LoginControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

// Read-only database
@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;

// User database
@property (nonatomic, strong) NSManagedObjectContext * userManagedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel * userManagedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator * userPersistentStoreCoordinator;

@property (nonatomic, strong) UINavigationController * navController;

@property (nonatomic, strong) MMDrawerController * drawerController;

//@property (nonatomic, strong) SMTabBarController * rootTabBarController;

- (void)saveUserContext;
- (void)attemptPushRegistration;

@end
