//
//  ShopDeliveryViewController.m
//  Exersite
//
//  Created by James Eunson on 11/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopDeliveryViewController.h"
#import "ProgressHUDHelper.h"
#import "ExersiteHTTPClient.h"
#import "ExersiteSession.h"
#import "ShopPaymentViewController.h"
#import "UIAlertView+Blocks.h"

@interface ShopDeliveryViewController ()

@property (nonatomic, strong) ExersiteHTTPClient * httpClient;
@property (nonatomic, strong) NSArray * storedAddresses;

@property (nonatomic, strong) MBProgressHUD * loadingView;

@property (nonatomic, strong) NSMutableDictionary * values;

@property (nonatomic, assign) BOOL storedAddressesAvailable;

- (void)_retrieveCountryStateInformation;
- (void)_submitForm:(id)sender;

- (void)_saveAddressDetailsOrContinue:(NSDictionary*)combinedValues;
- (NSMutableDictionary*)_updateCombinedValuesWithBillingInformation:(NSMutableDictionary*)unprocessedCombinedValues;

@end

@implementation ShopDeliveryViewController

- (id)init {
    self = [super init];
    if(self) {
        self.httpClient = [[ExersiteHTTPClient alloc] init];
        self.mode = ShopDeliveryViewControllerModeDeliveryAddress;
        self.billingAddressSameAsDelivery = YES;
    }
    return self;
}

// Second phase of process
//- (id)initWithValues:(NSMutableDictionary*)values {
//    self = [self init];
//    if(self) {
//        [self.values addEntriesFromDictionary:values];
//    }
//    return self;
//}

- (void)loadView {
    [super loadView];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail-stripes-bg"]];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    }
    
    ShopDeliveryScrollViewMode modeForScrollView = ShopDeliveryScrollViewModeDeliveryAddress;
    if(self.mode == ShopDeliveryViewControllerModeBillingAddress) {
        modeForScrollView = ShopDeliveryScrollViewModeBillingAddress;
    }
    
    self.scrollView = [[ShopDeliveryScrollView alloc] initWithMode:modeForScrollView];
    
    if(self.mode == ShopDeliveryViewControllerModeBillingAddress) {
        _scrollView.billingAddressSameAsDelivery = _billingAddressSameAsDelivery;
    }
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.deliveryDelegate = self;
    
    [self.view addSubview:_scrollView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_scrollView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Delivery";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(_submitForm:)];
    
    if(([[ExersiteSession currentSession] isUserLoggedIn] && self.mode != ShopDeliveryViewControllerModeBillingAddress) || (self.mode == ShopDeliveryViewControllerModeDeliveryAddress || (self.mode == ShopDeliveryViewControllerModeBillingAddress && !self.billingAddressSameAsDelivery))) {
        self.loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
    }
    
    // If user is logged in attempt to retrieve any stored addresses
    if([[ExersiteSession currentSession] isUserLoggedIn] && self.mode != ShopDeliveryViewControllerModeBillingAddress) {
        
        [_httpClient retrieveStoredAddressesWithCompletion:^(NSArray *result) {
            
            if(result && [result count] > 0) {
                self.scrollView.storedAddressesAvailable = YES;
                self.storedAddresses = result;
            }
            
            [self _retrieveCountryStateInformation];
        }];
        
    } else if(self.mode == ShopDeliveryViewControllerModeDeliveryAddress || (self.mode == ShopDeliveryViewControllerModeBillingAddress && !self.billingAddressSameAsDelivery)) {
            
        [self _retrieveCountryStateInformation];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // If user has registered and presses back, user registration should not be available again
    [self.scrollView reloadContent];
}

#pragma mark - Private Methods
// Called halfway through the submission process, should not be called outside didTapNextStepButton
// This just exists to reduce code duplication
- (void)_saveAddressDetailsOrContinue:(NSDictionary*)combinedValues {
    
    void (^continueCondition)(NSDictionary*) = ^(NSDictionary * selectedAddress){
        ShopPaymentViewController * paymentController = [[ShopPaymentViewController alloc] init];
        paymentController.selectedAddress = selectedAddress;
        [self.navigationController pushViewController:paymentController animated:YES];
    };
    
    // User elects to save the address for future use, push address to server and listen for a successful response
    // If successful, or even if we aren't move forward to payment section
    if(_scrollView.saveAddressForFutureUse) {
        
        // Have to remove display values before sending to server, so we create a "cleaned" version
        // to send to the server and create a mutable version of the address with all display values intact
        NSMutableDictionary * cleanedCombinedValues = [combinedValues mutableCopy];
        NSMutableDictionary * mutableCombinedValues = [combinedValues mutableCopy];
        
        NSArray * displayFields = [[[NSMutableArray alloc] initWithArray:kDeliveryDisplayFields] arrayByAddingObjectsFromArray:kBillingDisplayFields];
        for(NSString * deliveryDisplayField in displayFields) {
            if([[cleanedCombinedValues allKeys] containsObject:deliveryDisplayField]) {
//                NSLog(@"removing %@", deliveryDisplayField);
                [cleanedCombinedValues removeObjectForKey:deliveryDisplayField];
            }
        }
        
        [_httpClient createNewSavedAddressWithParameters:cleanedCombinedValues completion:^(NSDictionary *result) {
            
            if([result[@"success"] isEqualToString:@"true"]) { // Save successful
                
                // Add the saved address id to the address data package
                mutableCombinedValues[kAddressIdentifier] = result[@"id"];
                
                NSDictionary * updatedCombinedValues = [self _updateCombinedValuesWithBillingInformation:mutableCombinedValues];
                continueCondition(updatedCombinedValues);
                
            } else { // Server doesn't like the input for whatever reason, nothing we can do at this point, so show generic error message
                
                RIButtonItem * continueItem = [RIButtonItem itemWithLabel:@"OK"];
                continueItem.action = ^{
                    
                    NSDictionary * updatedCombinedValues = [self _updateCombinedValuesWithBillingInformation:[mutableCombinedValues mutableCopy]];
                    continueCondition(updatedCombinedValues);
                };
                
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, but an error occurred while trying to save your address. Please try again later." cancelButtonItem:continueItem otherButtonItems: nil];
                [alertView show];
            }
        }];
        
    } else { // User elects not to save address, process for display in payment controller in the next step
        
        NSDictionary * updatedCombinedValues = [self _updateCombinedValuesWithBillingInformation:[combinedValues mutableCopy]];
        continueCondition(updatedCombinedValues);
    }
}

- (NSMutableDictionary*)_updateCombinedValuesWithBillingInformation:(NSMutableDictionary*)unprocessedCombinedValues {
    
    // If billing address is not the same as delivery, all work is already complete
    if(![unprocessedCombinedValues[kBillingDetailsSameAsDelivery] boolValue]) {
        return unprocessedCombinedValues;
    }
    
    // Otherwise, we need to duplicate delivery field values into billing fields
    int i = 0;
    for(NSString * billingField in kBillingFields) {
        NSString * correspondingDeliveryField = kDeliveryFields[i];
        
        NSString * valueForDeliveryField = nil;
        if([[unprocessedCombinedValues allKeys] containsObject:correspondingDeliveryField]) { // Account for optional keys
            
            valueForDeliveryField = unprocessedCombinedValues[correspondingDeliveryField];
            unprocessedCombinedValues[billingField] = valueForDeliveryField;
        }
        

        i++;
    }
    
    // Duplicate display fields
    i = 0;
    for(NSString * billingDisplayField in kBillingDisplayFields) {
        NSString * correspondingDeliveryDisplayField = kDeliveryDisplayFields[i];
        
        // Account for non-existence with conditional, though that should not be the case here, as the user must pick title, state, country to continue
        // therefore display values will exist for each of these
        NSString * valueForDeliveryDisplayField = nil;
        if([[unprocessedCombinedValues allKeys] containsObject:correspondingDeliveryDisplayField]) {
            
            valueForDeliveryDisplayField = unprocessedCombinedValues[correspondingDeliveryDisplayField];
            unprocessedCombinedValues[billingDisplayField] = valueForDeliveryDisplayField;
        }
        
        i++;
    }
    
    // By this point, the dictionary is no longer "unprocessed", just in name only
    return unprocessedCombinedValues;
}

- (void)_retrieveCountryStateInformation {
    
    [_httpClient retrieveDeliveryCountriesForRequestQuote:^(NSArray * countries) {
        
        [_scrollView.deliveryCountries addObjectsFromArray:countries];
        _scrollView.selectedCountry = [countries firstObject];
        
        [_httpClient retrieveStatesForDeliveryCountryWithParameters:@{ @"code": _scrollView.selectedCountry[@"code"] } completion:^(NSArray *states) {
            
            [_scrollView.deliveryStates addObjectsFromArray:states];
            _scrollView.selectedState = [states firstObject];
            
            [_loadingView hide:YES];
        }];
    }];
}

- (void)_submitForm:(id)sender {
//    NSLog(@"submitForm");
    [self.scrollView submitForm];
}

#pragma mark - ShopDeliveryScrollViewDelegate
- (void)shopDeliveryScrollView:(ShopDeliveryScrollView*)shopDeliveryScrollView didTapChooseAddressButton:(ShopBigButton *)button {
//    NSLog(@"didTapChooseAddressButton");
    
    ShopChooseStoredAddressViewController * controller = [[ShopChooseStoredAddressViewController alloc] init];
    controller.storedAddresses = self.storedAddresses;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)shopDeliveryScrollView:(ShopDeliveryScrollView*)shopDeliveryScrollView didTapNextStepButton:(ShopBigButton*)button {
    
    if(self.mode == ShopDeliveryViewControllerModeDeliveryAddress) {
        
        ShopDeliveryViewController * controller = [[ShopDeliveryViewController alloc] init];
        controller.mode = ShopDeliveryViewControllerModeBillingAddress;
        controller.billingAddressSameAsDelivery = self.scrollView.billingAddressSameAsDelivery;
        
        NSDictionary * values = self.scrollView.values;
        controller.previousControllerValues = values;
        
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if(self.mode == ShopDeliveryViewControllerModeBillingAddress) {
        
        NSDictionary * values = _scrollView.values;
        NSMutableDictionary * combinedValues = [NSMutableDictionary dictionaryWithDictionary:values];
        
        for(NSString * key in [self.previousControllerValues allKeys]) {
            combinedValues[key] = self.previousControllerValues[key];
        }
        
        // If the user is not logged in, they must have entered registration information for a new account by this point, so validate
        // and then perform actions that are dependent on that (save address information if they have specified that it should be saved)
        if(![[ExersiteSession currentSession] isUserLoggedIn]) {
            
            NSMutableDictionary * accountValues = [[NSMutableDictionary alloc] init];
            for(NSString * accountField in kAccountFields) {
                accountValues[accountField] = values[accountField];
                
                // Must remove account field from combined values otherwise we get a mass-assignment error
                [combinedValues removeObjectForKey:accountField];
            }
            
            void (^errorCondition)(void) = ^(void){
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, but an error occurred while trying to register an account. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            };
            
            MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
            [_httpClient createNewUserAccountWithParameters:accountValues completion:^(NSDictionary *result) {
                
                [loadingView hide:YES];
                
                // Server didn't return anything usable at all, failure
                if(!result) {
                    errorCondition(); return;
                    
                } else {
                    
                    // Server returned something, determine whether we can do anything with it using the success key, if so, log the user in
                    if([result[@"success"] isEqualToString:@"true"]) {
                        
                        // Log user in
                        NSDictionary * userDetails = @{ @"email": accountValues[kAccountEmail], @"password": accountValues[kAccountPassword] };
                        
                        [ExersiteSessionAuthenticator authenticateWithUserDetails:userDetails completion:^(BOOL success) {
                            if(success) {
                                [self _saveAddressDetailsOrContinue:combinedValues];
                            }
                        }];
                        
                    } else {
                        
                        // Errors are missing or incomplete for whatever reason, just return a generic error
                        if(!result[@"errors"] || [result[@"errors"] count] == 0) {
                            errorCondition(); return;
                        }
                        
                        // Otherwise, pull out the first error and display it to the user
                        NSString * firstError = [NSString stringWithFormat:@"%@.", [result[@"errors"] firstObject]];
                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:firstError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alertView show];
                    }
                }
                
            }];
            
        } else {
            [self _saveAddressDetailsOrContinue:combinedValues];
        }
    }
}

// Retrieve states for newly selected country, and pass back to scrollview
- (void)shopDeliveryScrollView:(ShopDeliveryScrollView*)shopDeliveryScrollView didChangeSelectedCountry:(NSDictionary*)country {
    
    [_scrollView.deliveryStates removeAllObjects]; // Clear previously selected country states
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
    [_httpClient retrieveStatesForDeliveryCountryWithParameters:@{ @"code": country[@"code"] } completion:^(NSArray *states) {
        
        [_scrollView.deliveryStates addObjectsFromArray:states];
        _scrollView.selectedState = [states firstObject];
        
        // Tell the scrollview that visible states should change, if the pickerview is active, the content should immediately update
        // This is just a simple way around having to use KVO, although that would probably be cleaner
        [_scrollView didChangeDeliveryStates];
        
        [loadingView hide:YES];
    }];
}

#pragma mark - ShopChooseStoredAddressViewControllerDelegate Methods
- (void)shopChooseStoredAddressViewController:(ShopChooseStoredAddressViewController*)controller didChooseStoredAddress:(NSDictionary*)address {
//    NSLog(@"didChooseStoredAddress");
    
    ShopPaymentViewController * paymentController = [[ShopPaymentViewController alloc] init];
    paymentController.selectedAddress = address;
    [self.navigationController pushViewController:paymentController animated:YES];
}

@end
