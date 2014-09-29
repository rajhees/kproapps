//
//  ExersiteHTTPClient.h
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "AFHTTPClient.h"

typedef void (^DevicePushRegistrationResultBlock)(NSDictionary * result);
typedef void (^TimeZoneOffsetRegistrationResultBlock)(NSDictionary * result);
typedef void (^PrescribedProgramsBlock)(NSArray * programs);
typedef void (^RegistrationResultBlock)(NSDictionary * result);
typedef void (^PasswordResetResultBlock)(NSDictionary * result);

typedef void (^UpdateCompletionStatusBlock)(NSDictionary * result);
typedef void (^ShopListingResultBlock)(NSDictionary * result);
typedef void (^ShopRequestQuoteDeliveryCountryBlock)(NSArray * result);
typedef void (^ShopOrdersResultBlock)(NSDictionary * result);

typedef void (^PractitionerDetailsResultBlock)(NSDictionary * result);
typedef void (^NotificationsResultBlock)(NSDictionary * result);

typedef void (^ShopRequestQuoteSubmissionBlock)(NSDictionary * result);
typedef void (^ShopCheckoutStatesResultBlock)(NSArray * result);

typedef void (^ShopStoredAddressesResultBlock)(NSArray * result);
typedef void (^ShopCreateAccountResultBlock)(NSDictionary * result);
typedef void (^ShopCreateSavedAddressResultBlock)(NSDictionary * result);
typedef void (^ShopCreateOrderResultBlock)(NSDictionary * result);

#define kUserTimeZoneOffsetKey @"userTimeZoneOffsetKey"
#define kUserTimeZoneNameKey @"userTimeZoneNameKey"

@interface ExersiteHTTPClient : AFHTTPClient

// Registration
- (void)attemptSetDevicePushNotificationToken:(NSString*)token completion:(DevicePushRegistrationResultBlock)completion;
- (void)attemptSetUserTimeZoneOffsetParams:(NSDictionary*)timeZoneOffsetParams completion:(TimeZoneOffsetRegistrationResultBlock)completion;
- (void)attemptRegistrationWithParameters:(NSDictionary*)parameters completion:(RegistrationResultBlock)completion;
- (void)confirmRegistrationWithParameters:(NSDictionary*)parameters completion:(RegistrationResultBlock)completion;
- (void)resetPasswordWithParameters:(NSDictionary*)parameters completion:(PasswordResetResultBlock)completion;

// Prescription
- (void)retrievePrescribedProgramsWithCompletion:(PrescribedProgramsBlock)completion;
- (void)updateCompletionStatusForConcreteExerciseTimeWithParams:(NSDictionary*)params completion:(UpdateCompletionStatusBlock)completion;

// Misc User
- (void)retrievePractitionerDetailsWithCompletion:(PractitionerDetailsResultBlock)completion;
- (void)retrieveNotificationsWithCompletion:(NotificationsResultBlock)completion;

// Shop Content
- (void)retrieveShopListing:(ShopListingResultBlock)completion;
- (void)retrieveShopItemsForCategoryWithParameters:(NSDictionary*)parameters completion:(ShopListingResultBlock)completion;
- (void)searchShopWithQuery:(NSString*)query completion:(ShopListingResultBlock)completion;
- (void)retrieveOrders:(ShopOrdersResultBlock)completion;

// Shop Request Quote
- (void)retrieveDeliveryCountriesForRequestQuote:(ShopRequestQuoteDeliveryCountryBlock)completion;
- (void)submitRequestQuoteWithParameters:(NSDictionary*)parameters completion:(ShopRequestQuoteSubmissionBlock)completion;

// Shop Checkout
- (void)retrieveStatesForDeliveryCountryWithParameters:(NSDictionary*)parameters completion:(ShopCheckoutStatesResultBlock)completion;
- (void)retrieveStoredAddressesWithCompletion:(ShopStoredAddressesResultBlock)completion;

- (void)createNewUserAccountWithParameters:(NSDictionary*)parameters completion:(ShopCreateAccountResultBlock)completion;
- (void)createNewSavedAddressWithParameters:(NSDictionary*)parameters completion:(ShopCreateSavedAddressResultBlock)completion;
- (void)createNewOrderWithParameters:(NSDictionary*)parameters completion:(ShopCreateOrderResultBlock)completion;

@end
