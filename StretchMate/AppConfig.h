//
//  AppConfig.h
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyExercisesViewController.h"

#define kConfigStoreName @"ExersiteConfig"

#define kShopCartItemProductKey @"product"
#define kShopCartItemQuantityKey @"qty"

#define kLoggedInUserFullName @"loggedInUserFullName"
#define kLoggedInUserSessionExpiry @"loggedInUserSessionExpiry"
#define kLoggedInUserType @"loggedInUserType"
#define kLoggedInUserIdentifier @"loggedInUserIdentifier"

#define kShopCartItems @"shopCartItems"

#define kPushNotificationDeviceToken @"pushNotificationDeviceToken"
#define kPushNotificationDeviceTokenRecorded @"pushNotificationDeviceTokenRecorded"

#define kExerciseNowCompletingSwipeTipActionPerformed @"exerciseNowCompletingSwipeTipActionPerformed"
#define kExerciseNowCompletingStartFinishTipActionPerformed @"exerciseNowCompletingStartFinishTipActionPerformed"

#define kUserTimeZone @"userTimeZone"
#define kUserTimeZoneRecorded @"userTimeZoneRecorded"

#define kMyExercisesActiveFilterType @"myExercisesActiveFilterType"

#define kTutorialShown @"tutorialShown"

#define kProgramAlarmsEnabled @"programAlarmsEnabled"


// Store Key about the information of message alert (when user use the exercise 3 times, then show encourage message)

#define kExerciseThreeTimesEncourageKey @"exerciseThreetimesEncourage"
#define kExerciseThreeTimesCompletedKey @"exerciseThreetimesCompleted"

#define kExerciseTimeRecorded @"exerciseTimeRecorded"


@interface AppConfig : NSObject

@property (nonatomic, strong) NSMutableDictionary * configDict;

- (void)saveConfig;
- (void)setUpConfig;
- (void)resetConfig;

+ (AppConfig *)sharedConfig;

// Setters/getters required by IASKSettingsStore
- (void)setBool:(BOOL)value               forKey:(NSString*)key;
- (void)setDate:(NSDate*)date             forKey:(NSString*)key;
- (void)setDictionary:(NSDictionary*)dict forKey:(NSString*)key;
- (void)setFloat:(float)value             forKey:(NSString*)key;
- (void)setDouble:(double)value           forKey:(NSString*)key;
- (void)setObject:(id)object              forKey:(NSString*)key;
- (void)setInteger:(int)value             forKey:(NSString*)key;

- (BOOL)boolForKey:(NSString*)key;
- (float)floatForKey:(NSString*)key;
- (double)doubleForKey:(NSString*)key;
- (int)integerForKey:(NSString*)key;
- (id)objectForKey:(NSString*)key;

- (BOOL)synchronize;

- (NSString*)loggedInUserFullName;
- (NSDate*)loggedInUserSessionExpiry;
- (int)loggedInUserType;
- (int)loggedInUserIdentifier;

- (NSArray*)shopCartItems;
- (NSString*)shopCartItemsJson;

- (void)addShopCartItem:(NSDictionary*)product withQuantity:(NSInteger)qty;
- (void)removeShopCartItem:(NSDictionary*)cartItem;
- (double)shopCartSubtotal;
- (BOOL)isProductInCart:(NSDictionary*)product;

- (void)clearLoggedInUserInformation;

- (BOOL)exerciseNowCompletingSwipeTipActionPerformed;
- (BOOL)exerciseNowCompletingStartFinishTipActionPerformed;

- (MyExercisesViewControllerFilterType)myExercisesActiveFilterType;

- (NSString*)pushNotificationDeviceToken;
- (BOOL)pushNotificationDeviceTokenRecorded;

- (NSString*)userTimeZone;
- (BOOL)userTimeZoneRecorded;

- (BOOL)tutorialShown;

- (NSDictionary*)programAlarmsEnabled;

@end
