//
//  ExersiteHTTPClient.m
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExersiteHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "PractitionerExercise.h"
#import "Exercise.h"
#import "ShopRequestQuoteScrollView.h"
#import "Notification.h"

// Development API
#define kExersiteAPIBaseURL [NSURL URLWithString:@"http://localhost:3000"]
#define kExerciseStagingAPIBaseURL [NSURL URLWithString:@"http://exersite.jeon.com.au"]
#define kExerciseProductionAPIBaseURL [NSURL URLWithString:@"https://exersite.com.au"]

@implementation ExersiteHTTPClient

- (id)init {
    self = [super initWithBaseURL:kExersiteAPIBaseURL]; // TODO, before deployment
    if(self) {
        
        [self defaultValueForHeader:@"Accept"];
        
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    return self;
}

- (void)attemptSetDevicePushNotificationToken:(NSString*)token completion:(DevicePushRegistrationResultBlock)completion {
    
    if(!token) {
        completion(nil);
    }
    
    NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:@"/users/set-device-token.json" parameters: @{ @"token" : token }];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0 || ![[responseDict allKeys] containsObject:@"success"]) {
            completion(nil);
        }
        completion(responseDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to contact the Exersite server. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        completion(nil);
    }];
    [operation start];
}

- (void)attemptSetUserTimeZoneOffsetParams:(NSDictionary*)timeZoneOffsetParams completion:(TimeZoneOffsetRegistrationResultBlock)completion {
    
    
    NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:@"/users/set-time-zone.json" parameters: @{ @"time_zone_offset" : timeZoneOffsetParams[kUserTimeZoneOffsetKey], @"time_zone_name": timeZoneOffsetParams[kUserTimeZoneNameKey] }];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString * responseString = [operation responseString];
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0 || ![[responseDict allKeys] containsObject:@"success"]) {
            completion(nil);
        }
        completion(responseDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSString * responseString = [operation responseString];
//        NSLog(@"responseString: %@", responseString);
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to contact the Exersite server. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        completion(nil);
    }];
    [operation start];
}

- (void)retrievePrescribedProgramsWithCompletion:(PrescribedProgramsBlock)completion {
    
    NSDictionary * params = @{  };
    NSMutableURLRequest * request = [self requestWithMethod:@"GET" path:@"users/programs.json" parameters: params];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Check error conditions
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0 || ![[responseDict allKeys] containsObject:@"programs"] || [responseDict[@"programs"] count] == 0) {
            completion(nil);
        }
        
        NSMutableDictionary * mutableResponseDict = (NSMutableDictionary *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)responseDict, kCFPropertyListMutableContainers));
        NSArray * programsDicts = mutableResponseDict[@"programs"];        
        
        // Process - replace PractitionerExercise dicts with actual PractitionerExercise objects
        for(NSMutableDictionary * programDict in programsDicts) {
            if([[programDict allKeys] containsObject:@"exercises"]) { // PractitionerProgram
                
                // Create deep copy of exercises, so we can mutate it within a loop of the same content, without having to do it afterwards
                NSMutableArray * mutableExercises = CFBridgingRelease(CFPropertyListCreateDeepCopy(NULL, (CFArrayRef)programDict[@"exercises"], kCFPropertyListMutableContainersAndLeaves));
                
                for(NSDictionary * exercise in programDict[@"exercises"]) {
                    
                    if([[exercise allKeys] count] > 1) { // PractitionerExercise
                        NSError * error = nil;
                        
                        PractitionerExercise * practitionerExercise = [[PractitionerExercise alloc] initWithDictionary:exercise error:&error];
                        if(error) {
//                            NSLog(@"Unable to instantiate exercise from JSON: %@", [error localizedDescription]);
                        } else {
                            NSInteger indexOfCurrentExerciseDict = [programDict[@"exercises"] indexOfObject:exercise];
                            [mutableExercises replaceObjectAtIndex:indexOfCurrentExerciseDict withObject:practitionerExercise];
                        }
                    } else { // Normal exercise
                        
                        if([[exercise allKeys] containsObject:@"id"]) {
                            
                            NSNumber * identifier = @([exercise[@"id"] intValue]);
                            Exercise * stockExercise = [Exercise exerciseWithIdentifier:identifier];
                            
                            NSInteger indexOfCurrentExerciseDict = [programDict[@"exercises"] indexOfObject:exercise];
                            [mutableExercises replaceObjectAtIndex:indexOfCurrentExerciseDict withObject:stockExercise];
                            
                        } else {
//                            NSLog(@"Required exercise information not present");
                        }
                    }
                }
                
                // Replace with modified dict
                programDict[@"exercises"] = mutableExercises;
            }
        }
        
        completion(mutableResponseDict[@"programs"]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSString * responseString = [operation responseString];
//        NSLog(@"responseString: %@", responseString);
//        NSLog(@"failure: %@", [error localizedDescription]);
        completion(nil);
    }];
    [operation start];    
}

- (void)attemptRegistrationWithParameters:(NSDictionary*)parameters completion:(RegistrationResultBlock)completion {
    
//    NSLog(@"attemptRegistrationWithParameters");
    
    NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:@"signup/user/new.json" parameters: parameters];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString * responseString = [operation responseString];
//        NSLog(@"responseString: %@", responseString);
        
        // Check error conditions
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }
        
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0) {
            completion(@{@"success": @(NO)});
        }
        completion(responseDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
//        NSLog(@"error");
        completion(nil);
    }];
    [operation start];
}

- (void)confirmRegistrationWithParameters:(NSDictionary*)parameters completion:(RegistrationResultBlock)completion {
    
//    NSLog(@"confirmRegistrationWithParameters");
    
    NSMutableDictionary * mutableParameters = [parameters mutableCopy];
    NSString * pathString = [NSString stringWithFormat: @"/signup/user/claim/update/%@/%@.json", mutableParameters[@"code"], mutableParameters[@"dob"]];
    
    [mutableParameters removeObjectForKey:@"code"];
    [mutableParameters removeObjectForKey:@"dob"];
    parameters = [mutableParameters copy];
    
    NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:pathString parameters: parameters];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString * responseString = [operation responseString];
//        NSLog(@"responseString: %@", responseString);
        
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0) {
            completion(@{@"success": @(NO)});
        }
        completion(responseDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil);
    }];
    
    [operation start];
}

- (void)resetPasswordWithParameters:(NSDictionary*)parameters completion:(PasswordResetResultBlock)completion {
    
//    NSLog(@"confirmResetPasswordWithParameters");
    
    NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:@"/users/reset-password/create.json" parameters: parameters];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"success");
        
        NSString * responseString = [operation responseString];
//        NSLog(@"responseString: %@", responseString);
        
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0) {
            completion(@{@"success": @(NO)});
        }
        completion(responseDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"failure");
        completion(nil);
    }];
    [operation start];
}

- (void)updateCompletionStatusForConcreteExerciseTimeWithParams:(NSDictionary*)params completion:(UpdateCompletionStatusBlock)completion {
    
//    NSLog(@"updateCompletionStatusForConcreteExerciseTimeWithParams:");
    
    NSDictionary * parameters = @{ @"completed": ( [params[@"completed"] boolValue] ? @"true" : @"false" ) };
    NSString * pathForOperation = [NSString stringWithFormat:@"/users/programs/mark-completed/%@.json", params[@"id"]];
    
    NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:pathForOperation parameters: parameters];
    
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"success");
        
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0) {
            completion(@{@"success": @(NO)});
        }
        completion(responseDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"failure");
        completion(nil);
    }];
    [operation start];
}

- (void)retrievePractitionerDetailsWithCompletion:(PractitionerDetailsResultBlock)completion {
    
//    NSLog(@"retrievePractitionerDetailsWithCompletion:");
    
    NSMutableURLRequest * request = [self requestWithMethod:@"GET" path:@"/users/practitioner-details.json" parameters: nil];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"success");
        
        NSString * responseString = [operation responseString];
//        NSLog(@"responseString: %@", responseString);
        
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0) {
            completion(@{@"success": @(NO)});
        }
        completion(responseDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to contact the Exersite server. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        completion(nil);
    }];
    [operation start];
}

- (void)retrieveNotificationsWithCompletion:(NotificationsResultBlock)completion {
    
//    NSLog(@"retrieveNotificationsWithCompletion:");
    NSMutableURLRequest * request = [self requestWithMethod:@"GET" path:@"/users/notifications.json" parameters: nil];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0 || ![[responseDict allKeys] containsObject:@"notifications"] || ![responseDict[@"notifications"] isKindOfClass:[NSArray class]]) {
            completion(nil);
        }
        for(NSDictionary * notification in responseDict[@"notifications"]) {
            [Notification createNotificationFromNotificationDict:notification];
        }
        
        completion(responseDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to contact the Exersite server. Please check your connection and try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        completion(nil);
    }];
    [operation start];
}

- (void)retrieveShopListing:(ShopListingResultBlock)completion {
    
    NSMutableURLRequest * request = [self requestWithMethod:@"GET" path:@"/shop.json" parameters: nil];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"success");
        
        NSString * responseString = [operation responseString];
//        NSLog(@"responseString: %@", responseString);
        
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        
        // Detect irregularities in returned data
        if([[responseDict allKeys] count] == 0 || ![[responseDict allKeys] containsObject:@"items"] || ![[responseDict allKeys] containsObject:@"categories"] || [responseDict[@"items"] count] == 0 || [responseDict[@"categories"] count] == 0) {
            completion(nil);
        }
        
        completion(responseDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"failure: %@, %@", [error localizedDescription], [operation responseString]);
        completion(nil);
    }];
    [operation start];
}

- (void)retrieveShopItemsForCategoryWithParameters:(NSDictionary*)parameters completion:(ShopListingResultBlock)completion {
    
    NSString * categoryPath = [NSString stringWithFormat:@"/shop/category/%@.json", parameters[@"category"]];
    NSMutableURLRequest * request = [self requestWithMethod:@"GET" path:categoryPath parameters: nil];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) {
            completion(nil);
        }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0 || ![[responseDict allKeys] containsObject:@"items"] || [responseDict[@"items"] count] == 0) {
            completion(nil);
        }
        
        completion(responseDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"failure: %@", [error localizedDescription]);
        completion(nil);
    }];
    [operation start];
}

- (void)searchShopWithQuery:(NSString*)query completion:(ShopListingResultBlock)completion {
    
    NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:@"/shop/search.json" parameters: @{ @"q": query }];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) { completion(nil); } // Boilerplate
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0 || ![[responseDict allKeys] containsObject:@"results"] || [responseDict[@"results"] count] == 0) { completion(nil); return; }
        completion(responseDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) { completion(nil); }];
    [operation start];
}

- (void)retrieveOrders:(ShopOrdersResultBlock)completion {
    
    NSMutableURLRequest * request = [self requestWithMethod:@"GET" path:@"/shop/orders.json" parameters: nil];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) { completion(nil); } // Boilerplate
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0 || ![[responseDict allKeys] containsObject:@"orders"] || [responseDict[@"orders"] count] == 0) { completion(nil); return; }
        completion(responseDict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error: %@, %@", [error localizedDescription], [operation responseString]);        
        completion(nil);
    }];
    [operation start];
}

- (void)retrieveDeliveryCountriesForRequestQuote:(ShopRequestQuoteDeliveryCountryBlock)completion {

    NSMutableURLRequest * request = [self requestWithMethod:@"GET" path:@"/shop/request-quote.json" parameters: nil];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) { completion(nil); } // Boilerplate
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0 || ![[responseDict allKeys] containsObject:@"countries"] || [responseDict[@"countries"] count] == 0) { completion(nil); return; }
        completion(responseDict[@"countries"]);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) { completion(nil); }];
    [operation start];
}

- (void)submitRequestQuoteWithParameters:(NSDictionary*)parameters completion:(ShopRequestQuoteSubmissionBlock)completion {
    
    NSString * shopCartItemsJson = [[AppConfig sharedConfig] shopCartItemsJson];
    NSDictionary * processedParameters = @{ @"delivery_quote_request": @{ @"country": parameters[kRequestDetailsDeliveryCountryCodeKey], @"email": parameters[kRequestDetailsEmailKey] }, @"cart_items": shopCartItemsJson };
//    NSDictionary * processedParameters = @{ @"delivery_quote_request": @{ @"country": parameters[kRequestDetailsDeliveryCountryCodeKey], @"email": parameters[kRequestDetailsEmailKey] }, @"cart_items": @"{}" };
    
    NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:@"/shop/request-quote/create.json" parameters: processedParameters];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]]) { completion(nil); return; } // Boilerplate
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        if([[responseDict allKeys] count] == 0 || ![[responseDict allKeys] containsObject:@"success"]) { completion(nil); return; }
        completion(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) { completion(nil); }];
    [operation start];
}

- (void)retrieveStatesForDeliveryCountryWithParameters:(NSDictionary*)parameters completion:(ShopCheckoutStatesResultBlock)completion {
    
    NSString * pathString = [NSString stringWithFormat:@"/shop/checkout/order/state-list/delivery/%@.json", parameters[@"code"]];
    NSMutableURLRequest * request = [self requestWithMethod:@"GET" path:pathString parameters: nil];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]] || [[((NSDictionary*)responseObject) allKeys] count] == 0 || ![[((NSDictionary*)responseObject) allKeys] containsObject:@"states"]) { completion(nil); return; }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        completion(responseDict[@"states"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) { completion(nil);}];
    [operation start];
}

- (void)retrieveStoredAddressesWithCompletion:(ShopStoredAddressesResultBlock)completion {
    
    NSMutableURLRequest * request = [self requestWithMethod:@"GET" path:@"/shop/checkout/order/get-addresses" parameters: nil];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]] || [[((NSDictionary*)responseObject) allKeys] count] == 0 || ![[((NSDictionary*)responseObject) allKeys] containsObject:@"addresses"]) { completion(nil); return; }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        completion(responseDict[@"addresses"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error: %@, %@", [error localizedDescription], [operation responseString]);
        completion(nil);
    }];
    [operation start];
}

- (void)createNewSavedAddressWithParameters:(NSDictionary*)parameters completion:(ShopCreateSavedAddressResultBlock)completion {
    
    NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:@"/shop/checkout/order/create-saved-address" parameters: @{ @"shop_address_details": parameters }];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]] || [[((NSDictionary*)responseObject) allKeys] count] == 0 || ![[((NSDictionary*)responseObject) allKeys] containsObject:@"success"]) { completion(nil); return; }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        completion(responseDict);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error: %@, %@", [error localizedDescription], [operation responseString]);
        completion(nil);
    }];
    [operation start];
}

- (void)createNewUserAccountWithParameters:(NSDictionary*)parameters completion:(ShopCreateAccountResultBlock)completion {
 
    NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:@"/shop/checkout/order/create-account" parameters: parameters];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]] || [[((NSDictionary*)responseObject) allKeys] count] == 0 || ![[((NSDictionary*)responseObject) allKeys] containsObject:@"success"]) { completion(nil); return; }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        completion(responseDict);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error: %@, %@", [error localizedDescription], [operation responseString]);
        completion(nil);
    }];
    [operation start];
}

- (void)createNewOrderWithParameters:(NSDictionary*)parameters completion:(ShopCreateOrderResultBlock)completion {
    
    NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:@"/shop/checkout/order/create-order" parameters: parameters];
    AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(!responseObject || ![responseObject isKindOfClass:[NSDictionary class]] || [[((NSDictionary*)responseObject) allKeys] count] == 0 || ![[((NSDictionary*)responseObject) allKeys] containsObject:@"success"]) { completion(nil); return; }
        NSDictionary * responseDict = (NSDictionary*)responseObject;
        completion(responseDict);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error: %@, %@", [error localizedDescription], [operation responseString]);
        completion(nil);
    }];
    [operation start];
}

@end
