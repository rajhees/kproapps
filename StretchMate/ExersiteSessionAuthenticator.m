//
//  ExersiteSessionAuthenticator.m
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ProgressHUDHelper.h"
#import "AFJSONRequestOperation.h"
#import "KeychainItemWrapper.h"
#import "ExersiteSessionAuthenticator.h"
#import "ExersiteHTTPClient.h"
#import "ExersiteSession.h"

@interface ExersiteSessionAuthenticator ()

+ (void)attemptRecordUserTimeZone;

@end

@implementation ExersiteSessionAuthenticator

+ (void)authenticateWithUserDetails:(NSDictionary*)userDetails completion:(ExersiteSessionAuthenticatorResultBlock)completion {
    
    NSString * email = userDetails[@"email"];
    NSString * password = userDetails[@"password"];
    
    if(email.length == 0 || password.length == 0) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your account email and password to continue." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        completion(NO);
        return;
    }
    
    MBProgressHUD * hud = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
    ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
    
    NSDictionary * params = @{ @"session" : userDetails };
    NSMutableURLRequest * request = [httpClient requestWithMethod:@"POST" path:@"sessions.json" parameters: params];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, NSDictionary * responseObject) {
         
         [hud hide:YES];
         
         if(responseObject && [responseObject isKindOfClass:[NSDictionary class]] && [[responseObject allKeys] count] > 0) {
             
             NSString * valid = responseObject[@"valid"];
             if([valid isEqualToString:@"yes"]) {
                 
                NSString * name = responseObject[@"name"];
                NSNumber * userIdentifier = @([responseObject[@"user"] integerValue]);

                [[ExersiteSession currentSession] updateUserCredentialsWithEmail:email password:password];
                [[ExersiteSession currentSession] setUserFullName:name];
                [[ExersiteSession currentSession] setUserIdentifier:userIdentifier];

                ExersiteSession * session = [ExersiteSession currentSession];                 
                 
                if([[responseObject allKeys] containsObject:@"role"]) {
                    if([responseObject[@"role"] isEqualToString:@"practitioner"]) {
                        session.userType = ExersiteSessionUserTypePractitioner;
                    } else if([responseObject[@"role"] isEqualToString:@"patient"]) {
                        session.userType = ExersiteSessionUserTypePatient;
                    } else if([responseObject[@"role"] isEqualToString:@"user"]) {
                        session.userType = ExersiteSessionUserTypeUser;
                    }
                } else {
                    session.userType = ExersiteSessionUserTypeUser;
                }
 
                [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLoginNotification object:nil];
                 
                [ProgressHUDHelper showConfirmationHUDWithImage:[UIImage imageNamed:@"user"] withLabelText:[NSString stringWithFormat:@"Welcome %@", session.userFullName] withDetailsLabelText:@"You are logged in" withFadeTime:2.0f];
                
                if(![[AppConfig sharedConfig] userTimeZoneRecorded]) {
                    [self attemptRecordUserTimeZone];
                }
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
                 
                completion(YES);
                 
             } else {
                 
                 UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your username or password was incorrect, please check them and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alertView show];
                 
                 completion(NO);
             }
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         [hud hide:YES];
//         NSLog(@"error: %@", [operation error]);
         UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occurred while logging you in. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
         [alertView show];
         
         completion(NO);
     }];
    
    [operation start];
}

+ (void)attemptRecordUserTimeZone {
//    NSLog(@"attemptRecordUserTimeZone");
    
    NSDateFormatter *localTimeZoneFormatter = [NSDateFormatter new];
    localTimeZoneFormatter.timeZone = [NSTimeZone localTimeZone];
    localTimeZoneFormatter.dateFormat = @"Z";
    NSString *localTimeZoneOffset = [localTimeZoneFormatter stringFromDate:[NSDate date]];
    
    NSTimeZone *localTime = [NSTimeZone systemTimeZone];
    NSLog(@"Current local timezone  is  %@",[localTime name]);
    
    if(localTimeZoneOffset) {
        
        ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
        @try {
            
            NSDictionary * timezoneParams = @{ kUserTimeZoneNameKey : [localTime name], kUserTimeZoneOffsetKey: localTimeZoneOffset };
            [httpClient attemptSetUserTimeZoneOffsetParams:timezoneParams completion:^(NSDictionary *result) {
                NSLog(@"user time details set to %@", timezoneParams);
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"ERROR: Set user timezone information failed, reason: %@.", [exception reason]);
        }
    }
}

@end
