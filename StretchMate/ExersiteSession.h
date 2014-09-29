//
//  ExersiteSession.h
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeychainItemWrapper.h"
#import "ExersiteSessionAuthenticator.h"

#define kUserDidLogoutNotification @"userDidLogout"

typedef enum {
    ExersiteSessionUserTypePatient,
    ExersiteSessionUserTypePractitioner,
    ExersiteSessionUserTypeUser
} ExersiteSessionUserType;

#define kPatientDescription @"Patient"
#define kPractitionerDescription @"Practitioner"
#define kUserDescription @"User"

@interface ExersiteSession : NSObject

@property (nonatomic, strong) NSNumber * userIdentifier;
@property (nonatomic, strong) NSString * userFullName;
@property (nonatomic, strong) NSDate * expiryTime;
@property (nonatomic, assign) int userType;

@property (nonatomic, strong) KeychainItemWrapper * userCredentials;

- (BOOL)isSessionValid;
- (BOOL)isUserLoggedIn;

- (void)updateUserCredentialsWithEmail:(NSString*)email password:(NSString*)password;

- (void)destroySession;

+ (void)setCurrentSession:(ExersiteSession*)session;
+ (ExersiteSession*)currentSession;

- (NSString*)roleForUserType;

@end
