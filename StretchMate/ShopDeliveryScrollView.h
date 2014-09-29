//
//  ShopDeliveryScrollView.h
//  Exersite
//
//  Created by James Eunson on 11/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopBigButton.h"
#import "ShopCheckoutStepView.h"

#define kTitleOptions @[ @"MR", @"MS", @"MRS", @"MISS", @"DR" ]

#define kDeliveryTitle @"delivery_title"
#define kDeliveryFirstName @"delivery_first_name"
#define kDeliveryLastName @"delivery_last_name"
#define kDeliveryAddress @"delivery_address"
#define kDeliveryAddress2 @"delivery_address_2"
#define kDeliveryCountry @"delivery_country"
#define kDeliveryState @"delivery_state"
#define kDeliverySuburb @"delivery_suburb"
#define kDeliveryPostCode @"delivery_post_code"
#define kDeliveryEmail @"delivery_email"
#define kDeliveryTelephone @"delivery_telephone"

// These are not actually used in creating the order, only used
// for display in the ShopStoredAddressCell
#define kDeliveryTitleName @"delivery_title_name"
#define kDeliveryCountryName @"delivery_country_name"
#define kDeliveryStateName @"delivery_state_name"

#define kDeliveryDisplayFields @[ kDeliveryTitleName, kDeliveryCountryName,kDeliveryStateName  ]

#define kBillingTitleName @"billing_title_name"
#define kBillingCountryName @"billing_country_name"
#define kBillingStateName @"billing_state_name"

#define kBillingDisplayFields @[ kBillingTitleName, kBillingCountryName, kBillingStateName ]

// Only present if address is saved
#define kAddressIdentifier @"address_id"

#define kBillingDetailsSameAsDelivery @"billing_details_same_as_delivery"

#define kBillingTitle @"billing_title"
#define kBillingFirstName @"billing_first_name"
#define kBillingLastName @"billing_last_name"
#define kBillingAddress @"billing_address"
#define kBillingAddress2 @"billing_address_2"
#define kBillingCountry @"billing_country"
#define kBillingState @"billing_state"
#define kBillingSuburb @"billing_suburb"
#define kBillingPostCode @"billing_post_code"
#define kBillingEmail @"billing_email"
#define kBillingTelephone @"billing_telephone"

#define kDeliveryFields @[ kDeliveryTitle, kDeliveryFirstName, kDeliveryLastName, kDeliveryAddress, kDeliveryAddress2, kDeliveryCountry,\
kDeliveryState, kDeliverySuburb, kDeliveryPostCode, kDeliveryEmail, kDeliveryTelephone]

#define kBillingFields @[ kBillingTitle, kBillingFirstName, kBillingLastName, kBillingAddress, kBillingAddress2, kBillingCountry,\
kBillingState, kBillingSuburb, kBillingPostCode, kBillingEmail, kBillingTelephone]

// Account creation form that will appear for users purchasing as guest
#define kAccountName @"account_name"
#define kAccountEmail @"account_email"
#define kAccountPassword @"password"
#define kAccountPasswordConfirmation @"password_confirmation"

#define kAccountFields @[ kAccountName, kAccountEmail, kAccountPassword, kAccountPasswordConfirmation ]

typedef enum {
    ShopDeliveryScrollViewModeDeliveryAddress,
    ShopDeliveryScrollViewModeBillingAddress
} ShopDeliveryScrollViewMode;

@protocol ShopDeliveryScrollViewDelegate;
@interface ShopDeliveryScrollView : UIScrollView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) ShopCheckoutStepView * stepView;

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) CALayer * titleLabelBorder;
@property (nonatomic, strong) UILabel * introductionLabel;

@property (nonatomic, strong) CALayer * storedAddressBorder;
@property (nonatomic, strong) ShopBigButton * storedAddressChooseButton;
@property (nonatomic, strong) ShopBigButton * createNewAddressButton;
@property (nonatomic, strong) UILabel * createNewAddressDescriptionLabel;

@property (nonatomic, strong) ShopBigButton * nextStepButton;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, assign) __unsafe_unretained id<ShopDeliveryScrollViewDelegate> deliveryDelegate;
@property (nonatomic, strong) UIPickerView * pickerView;

@property (nonatomic, strong) NSMutableArray * deliveryCountries;
@property (nonatomic, strong) NSMutableArray * deliveryStates;

@property (nonatomic, strong) NSDictionary * selectedCountry;
@property (nonatomic, strong) NSDictionary * selectedState;

@property (nonatomic, assign) ShopDeliveryScrollViewMode mode;

@property (nonatomic, assign) BOOL storedAddressesAvailable;
@property (nonatomic, assign) BOOL billingAddressSameAsDelivery;
@property (nonatomic, assign) BOOL saveAddressForFutureUse;
@property (nonatomic, assign) BOOL createDeliveryAddressOptionsVisible;

@property (nonatomic, strong) NSMutableDictionary * values;

- (id)initWithMode:(ShopDeliveryScrollViewMode)mode;
+ (CGFloat)heightForScrollViewParameters:(NSDictionary*)parameters;

- (void)didChangeDeliveryStates;
- (void)submitForm;

- (void)reloadContent;

@end

@protocol ShopDeliveryScrollViewDelegate <NSObject>
- (void)shopDeliveryScrollView:(ShopDeliveryScrollView*)shopDeliveryScrollView didTapChooseAddressButton:(ShopBigButton*)button;
- (void)shopDeliveryScrollView:(ShopDeliveryScrollView*)shopDeliveryScrollView didTapNextStepButton:(ShopBigButton*)button;
- (void)shopDeliveryScrollView:(ShopDeliveryScrollView*)shopDeliveryScrollView didChangeSelectedCountry:(NSDictionary*)country;
@end
