//
//  AppConfig.m
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "AppConfig.h"
#import "SBJson.h"

// Defaults for all settings
#define kConfigDefaultsDict @{ \
    kExerciseNowCompletingSwipeTipActionPerformed : @(NO), \
    kExerciseNowCompletingStartFinishTipActionPerformed: @(NO), \
    kMyExercisesActiveFilterType: @(0), \
    kPushNotificationDeviceTokenRecorded: @(NO), \
    kUserTimeZoneRecorded: @(NO), \
    kTutorialShown: @(NO), \
    kProgramAlarmsEnabled: @{}, \
} \

@implementation AppConfig

+ (AppConfig *)sharedConfig
{
    static dispatch_once_t pred = 0;
    __strong static AppConfig *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    if (!(self = [super init]))
        return nil;
    
    [self setUpConfig];
    return self;
}

- (void)setDefaults {
    
    _configDict = [[NSMutableDictionary alloc] init];
    
    // Defaults
    _configDict[kExerciseNowCompletingSwipeTipActionPerformed] = kConfigDefaultsDict[kExerciseNowCompletingSwipeTipActionPerformed];
    _configDict[kExerciseNowCompletingStartFinishTipActionPerformed] = kConfigDefaultsDict[kExerciseNowCompletingStartFinishTipActionPerformed];
    
    _configDict[kMyExercisesActiveFilterType] = kConfigDefaultsDict[kMyExercisesActiveFilterType];
    _configDict[kPushNotificationDeviceTokenRecorded] = kConfigDefaultsDict[kPushNotificationDeviceTokenRecorded];
    _configDict[kUserTimeZoneRecorded] = kConfigDefaultsDict[kUserTimeZoneRecorded];
    _configDict[kTutorialShown] = kConfigDefaultsDict[kTutorialShown];
    
    _configDict[kProgramAlarmsEnabled] = kConfigDefaultsDict[kProgramAlarmsEnabled];
    
    [self saveConfig];
}

- (void)setUpConfig {
    
    _configDict = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfigStoreName]];
    if(!_configDict) {
        
        _configDict = [[NSMutableDictionary alloc] init];
        [self setDefaults];
    }
}

- (void)saveConfig {
    
    [[NSUserDefaults standardUserDefaults] setObject:_configDict forKey:kConfigStoreName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resetConfig {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kConfigStoreName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)loggedInUserFullName {
    return _configDict[kLoggedInUserFullName];
}

- (NSDate*)loggedInUserSessionExpiry {
    return _configDict[kLoggedInUserSessionExpiry];
}

- (int)loggedInUserType {
    return [_configDict[kLoggedInUserType] integerValue];
}

- (int)loggedInUserIdentifier {
    return [_configDict[kLoggedInUserIdentifier] integerValue];
}

- (NSArray*)shopCartItems {
    
    if(!_configDict[kShopCartItems]) {
        _configDict[kShopCartItems] = @[];
    }
    return _configDict[kShopCartItems];
}

- (NSString*)shopCartItemsJson {
    
    // Remove all non-essential information about products (ie everything but qty and id
    NSArray * shopCartItems = [[AppConfig sharedConfig] shopCartItems];
    NSMutableArray * processedShopCartItems = [[NSMutableArray alloc] init];
    
    for(NSDictionary * cartItem in shopCartItems) {
        [processedShopCartItems addObject:@{ @"id": cartItem[@"product"][@"id"], @"qty": cartItem[@"qty"] }];
    }
    
    SBJsonWriter * writer = [[SBJsonWriter alloc] init];
    return [writer stringWithObject:processedShopCartItems];
}

- (double)shopCartSubtotal {
    
    double subtotalAccumulator = 0;
    for(NSDictionary * cartItem in _configDict[kShopCartItems]) {
        
        double quantity = [cartItem[kShopCartItemQuantityKey] doubleValue];
        double price = [cartItem[kShopCartItemProductKey][@"price"] doubleValue];
        
        subtotalAccumulator += (quantity * price);
    }
    
    return subtotalAccumulator;
}

- (void)addShopCartItem:(NSDictionary*)product withQuantity:(NSInteger)qty {
    
    NSMutableArray * mutableShopCartItems = [[self shopCartItems] mutableCopy];
    [mutableShopCartItems addObject:@{ kShopCartItemProductKey: product, kShopCartItemQuantityKey: @(qty) }];
    
    _configDict[kShopCartItems] = mutableShopCartItems;
}

- (void)removeShopCartItem:(NSDictionary*)cartItem {
    
    NSMutableArray * mutableShopCartItems = [[self shopCartItems] mutableCopy];
    
    NSDictionary * itemToRemove = nil;
    for(NSDictionary * item in mutableShopCartItems) {
        if([item[kShopCartItemQuantityKey] integerValue] == [cartItem[kShopCartItemQuantityKey] integerValue] && [item[kShopCartItemProductKey][@"url"] isEqualToString:cartItem[kShopCartItemProductKey][@"url"]]) {
            itemToRemove = item; break;
        }
    }
    if(itemToRemove) {
        [mutableShopCartItems removeObject:itemToRemove];
    }
    
    _configDict[kShopCartItems] = mutableShopCartItems;
}

- (BOOL)isProductInCart:(NSDictionary *)product {
    
    BOOL productInCart = NO;
    
    for(NSDictionary * item in _configDict[kShopCartItems]) {
        NSDictionary * itemProduct = item[kShopCartItemProductKey];
        if([product[@"url"] isEqualToString:itemProduct[@"url"]]) { // url used as uniquely identifying key, because it is unique
            productInCart = YES; break;
        }
    }
    
    return productInCart;
}


- (void)clearLoggedInUserInformation {
    
    [_configDict removeObjectForKey:kLoggedInUserFullName];
    [_configDict removeObjectForKey:kLoggedInUserSessionExpiry];
    [_configDict removeObjectForKey:kLoggedInUserIdentifier];
    
    [self saveConfig];
}

- (BOOL)exerciseNowCompletingSwipeTipActionPerformed {
    if(![[_configDict allKeys] containsObject:kExerciseNowCompletingSwipeTipActionPerformed]) {
        [self setBool:[kConfigDefaultsDict[kExerciseNowCompletingSwipeTipActionPerformed] boolValue] forKey:kExerciseNowCompletingSwipeTipActionPerformed];
    }
    return [_configDict[kExerciseNowCompletingSwipeTipActionPerformed] boolValue];
}

- (BOOL)exerciseNowCompletingStartFinishTipActionPerformed {
    if(![[_configDict allKeys] containsObject:kExerciseNowCompletingStartFinishTipActionPerformed]) {
        [self setBool:[kConfigDefaultsDict[kExerciseNowCompletingStartFinishTipActionPerformed] boolValue] forKey:kExerciseNowCompletingStartFinishTipActionPerformed];
    }
    return [_configDict[kExerciseNowCompletingStartFinishTipActionPerformed] boolValue];
}

- (MyExercisesViewControllerFilterType)myExercisesActiveFilterType {
    if(![[_configDict allKeys] containsObject:kMyExercisesActiveFilterType]) {
        [self setInteger:[kConfigDefaultsDict[kMyExercisesActiveFilterType] integerValue] forKey:kMyExercisesActiveFilterType];
    }
    return [_configDict[kMyExercisesActiveFilterType] integerValue];
}

- (NSString*)pushNotificationDeviceToken {
    return _configDict[kPushNotificationDeviceToken];
}

- (BOOL)pushNotificationDeviceTokenRecorded {
    if(![[_configDict allKeys] containsObject:kPushNotificationDeviceTokenRecorded]) {
        [self setBool:[kConfigDefaultsDict[kPushNotificationDeviceTokenRecorded] boolValue] forKey:kPushNotificationDeviceTokenRecorded];
    }
    return [_configDict[kPushNotificationDeviceTokenRecorded] boolValue];
}

- (NSString*)userTimeZone {
    return _configDict[kUserTimeZone];
}

- (BOOL)userTimeZoneRecorded {
    if(![[_configDict allKeys] containsObject:kUserTimeZoneRecorded]) {
        [self setBool:[kConfigDefaultsDict[kUserTimeZoneRecorded] boolValue] forKey:kUserTimeZoneRecorded];
    }
    return [_configDict[kUserTimeZoneRecorded] boolValue];
}

- (BOOL)tutorialShown {
    if(![[_configDict allKeys] containsObject:kTutorialShown]) {
        [self setBool:[kConfigDefaultsDict[kTutorialShown] boolValue] forKey:kTutorialShown];
    }
    return [_configDict[kTutorialShown] boolValue];
}

- (NSDictionary*)programAlarmsEnabled {
    if(![[_configDict allKeys] containsObject:kProgramAlarmsEnabled]) {
        [self setObject:kConfigDefaultsDict[kProgramAlarmsEnabled] forKey:kProgramAlarmsEnabled];
    }
    return _configDict[kProgramAlarmsEnabled];
}


#pragma mark - IASKSettingsStore Methods
// Setters
- (void)setFloat:(float)value    forKey:(NSString*)key {
    _configDict[key] = @(value);
    [self saveConfig];
}
- (void)setDouble:(double)value  forKey:(NSString*)key {
    _configDict[key] = @(value);
    [self saveConfig];
}
- (void)setObject:(id)object forKey:(NSString*)key {
    _configDict[key] = object;
    [self saveConfig];
}
- (void)setInteger:(int)value forKey:(NSString*)key {
    _configDict[key] = @(value);
    [self saveConfig];
}
- (void)setBool:(BOOL)value forKey:(NSString *)key {
    _configDict[key] = @(value);
    [self saveConfig];
}
- (void)setDate:(NSDate*)date forKey:(NSString*)key {
    _configDict[key] = date;
    [self saveConfig];
}
- (void)setDictionary:(NSDictionary*)dict forKey:(NSString*)key {
    _configDict[key] = dict;
    [self saveConfig];
}

// Getters
- (BOOL)boolForKey:(NSString*)key {
    return [_configDict[key] boolValue];
}
- (float)floatForKey:(NSString*)key {
    return [_configDict[key] floatValue];
}
- (double)doubleForKey:(NSString*)key {
    return [_configDict[key] doubleValue];
}
- (int)integerForKey:(NSString*)key {
    return [_configDict[key] intValue];
}
- (id)objectForKey:(NSString*)key {
    return _configDict[key];
}

- (BOOL)synchronize {
    [self saveConfig];
    return YES;
}

@end
