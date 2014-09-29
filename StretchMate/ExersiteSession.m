//
//  ExersiteSession.m
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExersiteSession.h"

static ExersiteSession * _current = nil;

#define kExersiteSessionSeconds 60*60*24 // 24 hours

@interface ExersiteSession ()
- (void)_startSession;
@end

@implementation ExersiteSession
@synthesize userFullName = _userFullName;
@synthesize expiryTime = _expiryTime;
@synthesize userType = _userType;
@synthesize userIdentifier = _userIdentifier;

- (id)init {
    self = [super init];
    if(self) {
        self.userCredentials = [[KeychainItemWrapper alloc] initWithIdentifier:@"Exersite" accessGroup:nil];
    }
    return self;
}

// Checks expiry of session and retries login if necessary
- (BOOL)isSessionValid {
    if(self.expiryTime) {
        return ([_expiryTime compare:[NSDate date]] == NSOrderedAscending);
    } else {
        return NO;        
    }
}

// Checks if username and password are present in keychain
- (BOOL)isUserLoggedIn {
    return ([_userCredentials objectForKey:(__bridge id)kSecAttrAccount] != nil && [[_userCredentials objectForKey:(__bridge id)kSecAttrAccount] length] != 0) && ([_userCredentials objectForKey:(__bridge id)kSecValueData] != nil && [[_userCredentials objectForKey:(__bridge id)kSecValueData] length] != 0);
}

+ (void)setCurrentSession:(ExersiteSession*)session {
    _current = session;
}

+ (ExersiteSession*)currentSession {
    if(!_current) {
        _current = [[ExersiteSession alloc] init];
    }
    return _current;
}

- (void)destroySession {
    
    [_userCredentials setObject:@"" forKey:(__bridge id)kSecAttrAccount];
    [_userCredentials setObject:@"" forKey:(__bridge id)kSecValueData];
    
    [[AppConfig sharedConfig] clearLoggedInUserInformation];
    
    _expiryTime = nil;
    _userFullName = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLogoutNotification object:nil];
}

- (void)updateUserCredentialsWithEmail:(NSString*)email password:(NSString*)password {
    
    [_userCredentials setObject:email forKey:(__bridge id)kSecAttrAccount];
    [_userCredentials setObject:password forKey:(__bridge id)kSecValueData];
    
    [self _startSession];
}

- (NSString*)roleForUserType {
    
    int userType = [[AppConfig sharedConfig] loggedInUserType];
    
    if(userType == ExersiteSessionUserTypePatient) {
        return kPatientDescription;
    } else if(userType == ExersiteSessionUserTypePractitioner) {
        return kPractitionerDescription;
    } else if(userType == ExersiteSessionUserTypeUser) {
        return kUserDescription;
    } else { // Fallthrough, should not happen
        return kPatientDescription;
    }
}

#pragma mark - Private Methods
- (void)_startSession {
    
    // Record login time in epoch seconds, so the validity of it can be determined in the future
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSInteger nowSeconds = (NSInteger)now;
    
    NSDate * expiryTime = [NSDate dateWithTimeIntervalSince1970:(nowSeconds + kExersiteSessionSeconds)];
    self.expiryTime = expiryTime;
    
    [[AppConfig sharedConfig] setObject:_expiryTime forKey:kLoggedInUserSessionExpiry];
}

#pragma mark - Property Override Methods
- (NSString*)userFullName {
    
    // Retrieve persisted name, instead of in memory name
    NSString * storedUserFullName = [[AppConfig sharedConfig] loggedInUserFullName];
    return storedUserFullName;
}

- (void)setUserFullName:(NSString *)userFullName {
    _userFullName = userFullName;
    
    // Persist session full name between launches of app
    [[AppConfig sharedConfig] setObject:_userFullName forKey:kLoggedInUserFullName];
}

- (int)userType {
    return [[AppConfig sharedConfig] loggedInUserType];
}

- (void)setUserType:(int)userType {
    _userType = userType;
    [[AppConfig sharedConfig] setInteger:userType forKey:kLoggedInUserType];
}
- (void)setExpiryTime:(NSDate *)expiryTime {
    _expiryTime = expiryTime;
    
    // Persist session expiry between launches of app
    [[AppConfig sharedConfig] setObject:_expiryTime forKey:kLoggedInUserSessionExpiry];
}

- (NSDate*)expiryTime {
    
    NSDate * storedExpiryTime = [[AppConfig sharedConfig] loggedInUserSessionExpiry];
    return storedExpiryTime;
}

- (void)setUserIdentifier:(NSNumber *)userIdentifier {
    _userIdentifier = userIdentifier;
    
    [[AppConfig sharedConfig] setInteger:[userIdentifier integerValue] forKey:kLoggedInUserIdentifier];
}

- (NSNumber*)userIdentifier {
    return @([[AppConfig sharedConfig] loggedInUserIdentifier]);
}

@end
