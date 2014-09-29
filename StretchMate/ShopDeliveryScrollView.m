//
//  ShopDeliveryScrollView.m
//  Exersite
//
//  Created by James Eunson on 11/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopDeliveryScrollView.h"
#import "LoginSegmentedControlButton.h"
#import "ExersiteSession.h"
#import "RegexKitLite.h"

#define kDeliveryInstructionsString @"Enter your delivery address below. If your billing and delivery address are not the same, indicate this by selecting the marked button, and you will be able to enter your billing address. Please complete all fields, except where a field is marked optional."

#define kBillingInstructionsString @"Enter your billing address below. If your billing address is the same as your delivery address, go back and select this option at the bottom of the form. Please complete all fields, except where a field is marked optional."

#define kAccountInstructionsString @"Enter account details for your Exersite account below. You must create an account to place an order."

#define kDeliveryStoredAddressesAvailable @"You have addresses saved from previous orders. Use the button below to select a stored address, or enter a new address in the form below."

#define kDeliverySaveAddressInstructionsString @"You can save this address to speed up future transactions by selecting 'Yes' below."

// Defines order for fields
#define kDeliveryRequiredFields @[ kDeliveryTitle, kDeliveryFirstName, kDeliveryLastName, kDeliveryAddress, kDeliveryCountry,\
kDeliveryState, kDeliverySuburb, kDeliveryPostCode, kDeliveryEmail, kDeliveryTelephone]

#define kDeliveryTextFieldCells @[ kDeliveryTitle, kDeliveryFirstName, kDeliveryLastName, kDeliveryAddress, kDeliverySuburb, kDeliveryPostCode, kDeliveryEmail, kDeliveryTelephone ]
#define kDeliverySelectCells @[ kDeliveryTitle, kDeliveryCountry, kDeliveryState ]

// Definition of Billing fields, superficially the same as delivery fields, but relates to different actual field names
// ie. kDeliveryTitle vs kBillingTitle = "delivery_title" vs "billing_title", a distinction that is important for the server
#define kBillingRequiredFields @[ kBillingTitle, kBillingFirstName, kBillingLastName, kBillingAddress, kBillingCountry,\
kBillingState, kBillingSuburb, kBillingPostCode, kBillingEmail, kBillingTelephone]

#define kBillingTextFieldCells @[ kBillingTitle, kBillingFirstName, kBillingLastName, kBillingAddress, kBillingSuburb, kBillingPostCode, kBillingEmail, kBillingTelephone ]
#define kBillingSelectCells @[ kBillingTitle, kBillingCountry, kBillingState ]

// Fields placeholder/labels are the same in both, so used shared list
#define kLabelText @[ @"Title", @"First Name", @"Last Name", @"Address", @"Address 2 (optional)", @"Country", @"State", @"Suburb", @"Post Code", @"Email", @"Telephone" ]

// Account Registration fields
#define kAccountRequiredFields @[ kAccountName, kAccountEmail, kAccountPassword, kAccountPasswordConfirmation ]
#define kAccountLabelText @[ @"Accountholder Full Name", @"Account Email Address", @"Password", @"Confirm Password" ]

@interface ShopDeliveryScrollView ()

- (void)didTapChooseAddressButton:(id)sender;
- (void)didTapCreateNewAddressButton:(id)sender;
- (void)didTapPreviousNextFormElement:(id)sender;
- (void)didTapNextStepButton:(id)sender;
- (void)resignKeyboard:(id)sender;

- (void)registerForKeyboardNotifications;
- (void)unregisterKeyboardNotifications;
- (void)keyboardWasShown:(NSNotification*)notification;
- (void)keyboardWillBeHidden:(NSNotification*)notification;

- (UITextField*)_fieldForTag:(NSInteger)tag inFieldsGroup:(NSArray*)fieldsGroup;
- (void)_recordFieldValue:(UITextField*)field;

- (BOOL)_validateDeliveryBillingForm;
- (BOOL)_validateAccountForm;

- (void)textFieldDidChange:(UITextField*)field;

+ (NSString*)titleStringWithMode:(ShopDeliveryScrollViewMode)mode billingAddressSameAsDelivery:(BOOL)billingAddressSameAsDelivery;
+ (NSString*)introductionStringWithMode:(ShopDeliveryScrollViewMode)mode billingAddressSameAsDelivery:(BOOL)billingAddressSameAsDelivery storedAddressesAvailable:(BOOL)storedAddressesAvailable;

@property (nonatomic, strong) UITapGestureRecognizer * keyboardTapGestureRecognizer;
@property (nonatomic, strong) UITextField * selectedField;

@property (nonatomic, strong, readonly) UIToolbar * fieldToolbar;
@property (nonatomic, strong) CALayer * toolbarBottomBorder;

@property (nonatomic, strong) NSMutableArray * fields;
@property (nonatomic, strong) NSMutableArray * accountFields; // Used in billing mode only

@property (nonatomic, strong) CALayer * headerTopBorderLayer; // Preserved here, so can be re-laid out on rotation
@property (nonatomic, strong) CALayer * headerBottomBorderLayer; // Preserved here, so can be re-laid out on rotation
@property (nonatomic, strong) CALayer * tableViewBottomBorderLayer;

//@property (nonatomic, strong) UIView * heightView;

@end

@implementation ShopDeliveryScrollView
@synthesize fieldToolbar = _fieldToolbar;

- (void)dealloc {
    [self unregisterKeyboardNotifications];
}

- (id)initWithMode:(ShopDeliveryScrollViewMode)mode {
    self = [super init];
    if(self) {
        
        self.mode = mode;
        self.storedAddressesAvailable = NO;
        self.createDeliveryAddressOptionsVisible = YES;
        self.saveAddressForFutureUse = YES;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.fields = [[NSMutableArray alloc] init];
        self.accountFields = [[NSMutableArray alloc] init];
        
        self.values = [[NSMutableDictionary alloc] init];
        
        self.deliveryCountries = [[NSMutableArray alloc] init];
        self.deliveryStates = [[NSMutableArray alloc] init];
        
        self.stepView = [[ShopCheckoutStepView alloc] init];
        _stepView.selectedStep = ShopCheckoutStepDelivery;
        [self addSubview:_stepView];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = RGBCOLOR(57, 58, 70);
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        
        [self addSubview:_titleLabel];
        
        self.introductionLabel = [[UILabel alloc] init];
        _introductionLabel.font = [UIFont systemFontOfSize:13.0f];
        _introductionLabel.textColor = RGBCOLOR(99, 100, 109);
        _introductionLabel.backgroundColor = [UIColor clearColor];
        _introductionLabel.numberOfLines = 0;
        _introductionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_introductionLabel];
        
        self.titleLabelBorder = [CALayer layer];
        [_titleLabelBorder setBackgroundColor:RGBCOLOR(221, 221, 221).CGColor];
        [self.layer addSublayer:_titleLabelBorder];
        
        self.createNewAddressDescriptionLabel = [[UILabel alloc] init];
        _createNewAddressDescriptionLabel.font = [UIFont systemFontOfSize:13.0f];
        _createNewAddressDescriptionLabel.textColor = RGBCOLOR(99, 100, 109);
        _createNewAddressDescriptionLabel.backgroundColor = [UIColor clearColor];
        _createNewAddressDescriptionLabel.numberOfLines = 0;
        _createNewAddressDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _createNewAddressDescriptionLabel.text = kDeliveryInstructionsString;
        _createNewAddressDescriptionLabel.hidden = YES;
        [self addSubview:_createNewAddressDescriptionLabel];
        
        self.storedAddressChooseButton = [[ShopBigButton alloc] init];
        [_storedAddressChooseButton addTarget:self action:@selector(didTapChooseAddressButton:) forControlEvents:UIControlEventTouchUpInside];
        _storedAddressChooseButton.type = ShopBigButtonTypeChooseAddress;
        _storedAddressChooseButton.hidden = YES;
        [self addSubview:_storedAddressChooseButton];
        
        self.createNewAddressButton = [[ShopBigButton alloc] init];
        [_createNewAddressButton addTarget:self action:@selector(didTapCreateNewAddressButton:) forControlEvents:UIControlEventTouchUpInside];
        _createNewAddressButton.type = ShopBigButtonTypeCreateNewAddress;
        _createNewAddressButton.hidden = YES;
        [self addSubview:_createNewAddressButton];
        
        self.storedAddressBorder = [CALayer layer];
        [_storedAddressBorder setBackgroundColor:RGBCOLOR(221, 221, 221).CGColor];
        _storedAddressBorder.hidden = YES;
        [self.layer addSublayer:_storedAddressBorder];
        
        self.tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.scrollEnabled = NO;
        [self addSubview:_tableView];
        
        self.pickerView = [[UIPickerView alloc] init];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        
        self.tableViewBottomBorderLayer = [CALayer layer];
        [_tableViewBottomBorderLayer setBackgroundColor:RGBCOLOR(221, 221, 221).CGColor];
        [self.layer addSublayer:_tableViewBottomBorderLayer];
        
        self.nextStepButton = [[ShopBigButton alloc] init];
        _nextStepButton.type = ShopBigButtonTypeNextStep;
        [_nextStepButton addTarget:self action:@selector(didTapNextStepButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_nextStepButton];
        
        self.billingAddressSameAsDelivery = YES;
        
//        self.heightView = [[UIView alloc] init];
//        _heightView.userInteractionEnabled = NO;
//        _heightView.backgroundColor = [UIColor redColor];
//        _heightView.alpha = 0.3f;
//        [self addSubview:_heightView];
        
        [self registerForKeyboardNotifications];
        
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.stepView.frame = CGRectMake(0, 0, self.frame.size.width, 33.0f);
    
    CGSize sizeForTitleLabel = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    self.titleLabel.frame = CGRectMake(8, _stepView.frame.size.height + 12.0f, sizeForTitleLabel.width, sizeForTitleLabel.height);
    
    CGSize sizeForIntroductionLabel = [self.introductionLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    _introductionLabel.frame = CGRectMake(8.0f, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 8.0f, self.frame.size.width - 16.0f, sizeForIntroductionLabel.height);
    
    CGFloat headerHeight = [self tableView:_tableView heightForHeaderInSection:1];
    CGFloat tableStartingPoint = 0;
    
    if(self.storedAddressesAvailable) {
        
        [_titleLabelBorder setFrame:CGRectMake(0, _introductionLabel.frame.origin.y + _introductionLabel.frame.size.height + 12.0f, self.frame.size.width, 1)];
        
        _storedAddressChooseButton.frame = CGRectMake(8.0f, _titleLabelBorder.frame.origin.y + _titleLabelBorder.frame.size.height + 8.0f, self.frame.size.width - 16.0f, 44.0f);
        
        if(!_createDeliveryAddressOptionsVisible) {
            _createNewAddressButton.frame = CGRectMake(8.0f, _storedAddressChooseButton.frame.origin.y + _storedAddressChooseButton.frame.size.height + 8.0f, self.frame.size.width - 16.0f, 44.0f);
            
            _storedAddressBorder.frame = CGRectMake(0, _createNewAddressButton.frame.origin.y + _createNewAddressButton.frame.size.height + 12.0f, self.frame.size.width, 1.0f);
            tableStartingPoint = _storedAddressBorder.frame.origin.y + _storedAddressBorder.frame.size.height;
            
        } else {
            
            CGSize sizeForCreateNewAddressDescriptionLabel = [_createNewAddressDescriptionLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            _createNewAddressDescriptionLabel.frame = CGRectMake(8.0f, _storedAddressChooseButton.frame.origin.y + _storedAddressChooseButton.frame.size.height + 8.0f, sizeForCreateNewAddressDescriptionLabel.width, sizeForCreateNewAddressDescriptionLabel.height);
            
            _storedAddressBorder.frame = CGRectMake(0, _createNewAddressDescriptionLabel.frame.origin.y + _createNewAddressDescriptionLabel.frame.size.height + 11.0f, self.frame.size.width, 1.0f);
            
            tableStartingPoint = _createNewAddressDescriptionLabel.frame.origin.y + _createNewAddressDescriptionLabel.frame.size.height + 12.0f;
        }
        
    } else {
        
        [_titleLabelBorder setFrame:CGRectMake(0, _introductionLabel.frame.origin.y + _introductionLabel.frame.size.height + 19.0f, self.frame.size.width, 1)];
        tableStartingPoint = _titleLabelBorder.frame.origin.y + _titleLabelBorder.frame.size.height;
    }
    
    if(self.storedAddressesAvailable && !_createDeliveryAddressOptionsVisible) {
        _tableView.frame = CGRectMake(0, tableStartingPoint, self.frame.size.width, 0);
    } else {
        if(self.mode == ShopDeliveryScrollViewModeDeliveryAddress) {
            _tableView.frame = CGRectMake(0, tableStartingPoint, self.frame.size.width, ([kDeliveryFields count] * 44.0f) + (2 * 44.0f) + headerHeight);
        } else {
            
            if([[ExersiteSession currentSession] isUserLoggedIn]) {
                if(self.billingAddressSameAsDelivery) {
                    _tableView.frame = CGRectMake(0, tableStartingPoint, self.frame.size.width, (2 * 44.0f));
                } else {
                    CGFloat heightForSaveForFutureUseHeader = [self tableView:_tableView heightForHeaderInSection:2];
                    _tableView.frame = CGRectMake(0, tableStartingPoint, self.frame.size.width, ([kBillingFields count] * 44.0f) + (2 * 44.0f) + heightForSaveForFutureUseHeader);
                }
            } else {
                if(self.billingAddressSameAsDelivery) {
                    _tableView.frame = CGRectMake(0, tableStartingPoint, self.frame.size.width, ([kAccountFields count] * 44.0f) + (2 * 44.0f) + headerHeight);
                } else {
                    CGFloat heightForSaveForFutureUseHeader = [self tableView:_tableView heightForHeaderInSection:2];
                    _tableView.frame = CGRectMake(0, tableStartingPoint, self.frame.size.width, ([kBillingFields count] * 44.0f) + ([kAccountFields count] * 44.0f) + (2 * 44.0f) + headerHeight + heightForSaveForFutureUseHeader);
                }
            }
        }
    }
    
    _tableViewBottomBorderLayer.frame = CGRectMake(0, _tableView.frame.origin.y + _tableView.frame.size.height, self.frame.size.width, 1.0f);
    
    _nextStepButton.frame = CGRectMake(8.0f, _tableView.frame.origin.y + _tableView.frame.size.height + 8.0f, self.frame.size.width - 16.0f, 44.0f);
    
    _headerTopBorderLayer.frame = CGRectMake(0, 0, self.frame.size.width, 1.0f);
    _headerBottomBorderLayer.frame = CGRectMake(0, headerHeight - 1.0f, self.frame.size.width, 1.0f);
    
//    _heightView.frame = CGRectMake(0, 0, self.frame.size.width, [[self class] heightForScrollViewParameters:@{ @"storedAddressesAvailable": @(self.storedAddressesAvailable), @"createDeliveryAddressOptionsVisible": @(self.createDeliveryAddressOptionsVisible), @"mode": @(self.mode), @"billingAddressSameAsDelivery": @(self.billingAddressSameAsDelivery) }]);
    
    self.contentSize = CGSizeMake(self.frame.size.width, [[self class] heightForScrollViewParameters:@{ @"storedAddressesAvailable": @(self.storedAddressesAvailable), @"createDeliveryAddressOptionsVisible": @(self.createDeliveryAddressOptionsVisible), @"mode": @(self.mode), @"billingAddressSameAsDelivery": @(self.billingAddressSameAsDelivery) }]);
}

- (void)reloadContent {
    
    _titleLabel.text = [[self class] titleStringWithMode:self.mode billingAddressSameAsDelivery:self.billingAddressSameAsDelivery];
    _introductionLabel.text = [[self class] introductionStringWithMode:self.mode billingAddressSameAsDelivery:self.billingAddressSameAsDelivery storedAddressesAvailable:self.storedAddressesAvailable];
    
    [self.tableView reloadData];
    [self setNeedsLayout];
}

// Required keys in parameters
// storedAddressesAvailable, createDeliveryAddressOptionsVisible, mode, billingAddressSameAsDelivery
+ (CGFloat)heightForScrollViewParameters:(NSDictionary*)parameters {
    
    if(![[parameters allKeys] containsObject:@"storedAddressesAvailable"] || ![[parameters allKeys] containsObject:@"createDeliveryAddressOptionsVisible"] || ![[parameters allKeys] containsObject:@"mode"] || ![[parameters allKeys] containsObject:@"billingAddressSameAsDelivery"]) {
        
//        NSLog(@"Missing parameter while generating height for ShopDeliveryScrollView");
        return 1000.0f;
    }
    
    ShopDeliveryScrollViewMode mode = [parameters[@"mode"] integerValue];
    BOOL storedAddressesAvailable = [parameters[@"storedAddressesAvailable"] boolValue];
    BOOL createDeliveryAddressOptionsVisible = [parameters[@"createDeliveryAddressOptionsVisible"] boolValue];
    BOOL billingAddressSameAsDelivery = [parameters[@"billingAddressSameAsDelivery"] boolValue];
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGFloat heightAccumulator = 33.0f; // Step view
    
    NSString * titleString = [[self class] titleStringWithMode:mode billingAddressSameAsDelivery:billingAddressSameAsDelivery];
    NSString * introductionString = [[self class] introductionStringWithMode:mode billingAddressSameAsDelivery:billingAddressSameAsDelivery storedAddressesAvailable:storedAddressesAvailable];
    
    // Determine height for everything preceding the tableview
    CGSize sizeForTitleLabel = [titleString sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    heightAccumulator += sizeForTitleLabel.height + 8.0f; // Height + padding
    
    CGSize sizeForIntroductionLabel = [introductionString sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    heightAccumulator += sizeForIntroductionLabel.height;
    
    if(storedAddressesAvailable) {
        
        heightAccumulator += 12.0f + 1.0f + 8.0f + 44.0f;
        
        if(!createDeliveryAddressOptionsVisible) {
            heightAccumulator += 8.0f + 44.0f + 12.0f + 1.0f + 13.0f;
            
        } else {
            CGSize sizeForCreateNewAddressDescriptionLabel = [kDeliveryInstructionsString sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            heightAccumulator += 8.0f + sizeForCreateNewAddressDescriptionLabel.height + 11.0f + 1.0f + 12.0f;
        }
        
    } else {
        heightAccumulator += 12.0f + 20.0f;
    }
    
    // Determine height of tableview
    NSString * sectionTitle = nil;
    if(mode == ShopDeliveryScrollViewModeDeliveryAddress) {
        sectionTitle = @"Billing address same as delivery address?";
    } else if(mode == ShopDeliveryScrollViewModeBillingAddress && !billingAddressSameAsDelivery) {
        sectionTitle = @"Exersite Account";
    } else if(mode == ShopDeliveryScrollViewModeBillingAddress && billingAddressSameAsDelivery) {
        sectionTitle = @"Save address for future use?";
    }
    
    CGSize sizeForHeaderTitle = [sectionTitle sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat headerHeight = roundf(sizeForHeaderTitle.height) + 24.0f;
    
    if(storedAddressesAvailable && !createDeliveryAddressOptionsVisible) {
        heightAccumulator += 0;
    } else {
        if(mode == ShopDeliveryScrollViewModeDeliveryAddress) {
            heightAccumulator += ([kDeliveryFields count] * 44.0f) + (2 * 44.0f) + headerHeight;
            
        } else {
            
            if([[ExersiteSession currentSession] isUserLoggedIn]) {
                if(billingAddressSameAsDelivery) {
                    heightAccumulator += (2 * 44.0f);
                } else {
                    
                    NSString * secondHeaderTitle = @"Save address for future use?";
                    CGSize sizeForSecondHeaderTitle = [secondHeaderTitle sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
                    CGFloat secondHeaderHeight = roundf(sizeForSecondHeaderTitle.height) + 24.0f;
                    heightAccumulator += ([kBillingFields count] * 44.0f) + (2 * 44.0f) + secondHeaderHeight;
                }
                
            } else {
             
                if(billingAddressSameAsDelivery) {
                    heightAccumulator += ([kAccountFields count] * 44.0f) + (2 * 44.0f) + headerHeight;
                } else {
                    
                    NSString * secondHeaderTitle = @"Save address for future use?";
                    CGSize sizeForSecondHeaderTitle = [secondHeaderTitle sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
                    CGFloat secondHeaderHeight = roundf(sizeForSecondHeaderTitle.height) + 24.0f;
                    heightAccumulator += ([kBillingFields count] * 44.0f) + ([kAccountFields count] * 44.0f) + (2 * 44.0f) + headerHeight + secondHeaderHeight;
                }
            }
        }
    }
    
    if(createDeliveryAddressOptionsVisible) {
        heightAccumulator += 8.0f + 44.0f + 20.0f;
    }
    
    return heightAccumulator;
}

- (void)didChangeDeliveryStates {
//    NSLog(@"didChangeDeliveryStates");
    
    if(_selectedField.tag == [kLabelText indexOfObject:@"State"]) {
        
        if(_selectedState) {
            _selectedField.text = _selectedState[@"title"];
        }
        [self.pickerView reloadAllComponents];
    }
}

- (void)submitForm {
//    NSLog(@"submitForm");
    
    // Validate delivery or billing forms
    BOOL valid = YES;
    
    if(self.mode == ShopDeliveryScrollViewModeDeliveryAddress || (self.mode == ShopDeliveryScrollViewModeBillingAddress && !self.billingAddressSameAsDelivery)) {
        valid = [self _validateDeliveryBillingForm];
    }
    
    // Only validate accountFields if there was no error with preceding sections
    if(valid && [_accountFields count] > 0) {
        valid = [self _validateAccountForm];
    }
    
    if(valid) {
        if([self.deliveryDelegate respondsToSelector:@selector(shopDeliveryScrollView:didTapNextStepButton:)]) {
            [self.deliveryDelegate performSelector:@selector(shopDeliveryScrollView:didTapNextStepButton:) withObject:self withObject:_nextStepButton];
        }
    }
}

#pragma mark - UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _selectedField = textField;
    
    NSMutableArray * fieldsGroup = _fields;
    if([_fields indexOfObject:_selectedField] == NSNotFound && self.mode == ShopDeliveryScrollViewModeBillingAddress) {
        fieldsGroup = _accountFields;
    }
    
    if(fieldsGroup == _fields) {
        
        // Initialize field, if empty
        if(_selectedField.tag == [kLabelText indexOfObject:@"Title"] && _selectedField.text.length == 0) {
            _selectedField.text = kTitleOptions[0];
            
        } else if(_selectedField.tag == [kLabelText indexOfObject:@"Country"] && _selectedField.text.length == 0) {
            _selectedField.text = _selectedCountry[@"title"];
            
        } else if(_selectedField.tag == [kLabelText indexOfObject:@"State"] && _selectedField.text.length == 0) {
            _selectedField.text = _selectedState[@"title"];
        }
        
        // Update with new data for selected field, otherwise picker displays last field content instead of current content
        if(_selectedField.tag == [kLabelText indexOfObject:@"Title"] || _selectedField.tag == [kLabelText indexOfObject:@"Country"] || _selectedField.tag == [kLabelText indexOfObject:@"State"]) {
            
            [self.pickerView reloadAllComponents];
            
            // Set pickerview to user selected value, otherwise it seems to pick an arbitrary row as currently selected
            UIPickerView * inputView = (UIPickerView*)textField.inputView;
            
            if(_selectedField.tag == [kLabelText indexOfObject:@"Title"] && [[_values allKeys] containsObject:kDeliveryTitle]) {
                [inputView selectRow:[_values[kDeliveryTitle] integerValue] inComponent:0 animated:NO];
                
            } else if(_selectedField.tag == [kLabelText indexOfObject:@"Country"] && [[_values allKeys] containsObject:kDeliveryCountry]) {
                
                NSInteger indexOfCountry = [_deliveryCountries indexOfObject:_selectedCountry];
                if(indexOfCountry != NSNotFound) {
                    [inputView selectRow:indexOfCountry inComponent:0 animated:NO];
                }
            }
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)field {
    
    // If user is picking country for the first time, or the user has changed the country setting, load new states
    if(field.tag == [kLabelText indexOfObject:@"Country"]) {
        if(![[_values allKeys] containsObject:kDeliveryCountry] || ![_values[kDeliveryCountry] isEqualToString:_selectedCountry[@"code"]]) {
            
            [self _recordFieldValue:field];
            
            if([self.deliveryDelegate respondsToSelector:@selector(shopDeliveryScrollView:didTapChooseAddressButton:)]) {
                [self.deliveryDelegate performSelector:@selector(shopDeliveryScrollView:didChangeSelectedCountry:) withObject:self withObject:_selectedCountry];
            }
        }
    } else {
        [self _recordFieldValue:field];
    }
    
    [self _recordFieldValue:field];
    _selectedField = nil;
}

- (void)textFieldDidChange:(UITextField*)field {
    
    if(field.tag == [kLabelText indexOfObject:@"Country"]) {
        
        _selectedState = nil;
        [_values removeObjectForKey:kDeliveryState];
        
        NSInteger stateRowIndex = [kDeliveryFields indexOfObject:kDeliveryState];
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:stateRowIndex inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self _recordFieldValue:field];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(textField.tag == [kLabelText indexOfObject:@"Telephone"]) {
        [textField resignFirstResponder];
        return YES;
        
    } else {
        
        NSInteger tagForField = _selectedField.tag;
        
        NSMutableArray * fieldsGroup = _fields;
        if([_fields indexOfObject:_selectedField] == NSNotFound && self.mode == ShopDeliveryScrollViewModeBillingAddress) {
            fieldsGroup = _accountFields;
        }
        
        UITextField * textField = [self _fieldForTag:(tagForField + 1) inFieldsGroup:fieldsGroup];
        if(textField) {
            [textField becomeFirstResponder];
        }
        return NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Should be able to edit field that does not have an input view (field is not associated with a UIPickerView)
    // and no textual editing should be able to take place for a field that IS associated with a UIPickerView
    
    if(!textField.inputView) {
        return YES;
    }
    
    return NO;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.mode == ShopDeliveryScrollViewModeDeliveryAddress && indexPath.section == 1) {
        if(indexPath.row == 0) {
            self.billingAddressSameAsDelivery = YES;
        } else {
            self.billingAddressSameAsDelivery = NO;
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1]  ] withRowAnimation:UITableViewRowAnimationNone];
        
    } else if(self.mode == ShopDeliveryScrollViewModeBillingAddress && indexPath.section == ([self numberOfSectionsInTableView:_tableView] - 1)) {
        if(indexPath.row == 0) {
            self.saveAddressForFutureUse = YES;
        } else {
            self.saveAddressForFutureUse = NO;
        }
        
        NSInteger lastSectionIndex = ([self numberOfSectionsInTableView:_tableView] - 1);
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:lastSectionIndex], [NSIndexPath indexPathForRow:1 inSection:lastSectionIndex]  ] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(self.mode == ShopDeliveryScrollViewModeBillingAddress) {
        
        // If user is logged in, don't display the create new account part of the billing form
        if([[ExersiteSession currentSession] isUserLoggedIn]) {
            if(self.billingAddressSameAsDelivery) {
                return 1;
            } else {
                return 2;
            }
        } else {
            
            // Otherwise, display billing address form, create new account form and the "save address" form
            if(self.billingAddressSameAsDelivery) {
                return 2; // Hide billing address form
            } else {
                return 3;
            }
        }
        
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // If billing/delivery addresses are the same, don't display billing form
    if(self.mode == ShopDeliveryScrollViewModeBillingAddress) {
        
        if([[ExersiteSession currentSession] isUserLoggedIn]) {
            
            if(self.billingAddressSameAsDelivery) {
                return 2;
                
            } else {
                if(section == 0) {
                    return [kBillingFields count];
                } else {
                    return 2;
                }
            }
            
        } else {
            
            if(self.billingAddressSameAsDelivery) {
                
                if(section == 0) {
                    return [kAccountFields count];
                } else {
                    return 2;
                }
                
            } else {
                
                if(section == 0) {
                    return [kBillingFields count];
                } else if(section == 1) {
                    return [kAccountFields count];
                } else {
                    return 2;
                }
            }
        }
        
    } else {
        
        if(section == 0) {
            
            if(self.storedAddressesAvailable && !_createDeliveryAddressOptionsVisible) {
                return 0;
            } else {
                return [kDeliveryFields count];
            }
        } else {
            if(self.storedAddressesAvailable && !_createDeliveryAddressOptionsVisible) {
                return 0;
            } else {
                return 2;
            }
        }
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(self.mode == ShopDeliveryScrollViewModeDeliveryAddress) {
        if(section == 1) {
            return @"Billing address same as delivery address?";
        }
        
    } else if(self.mode == ShopDeliveryScrollViewModeBillingAddress) {
        
        // Sections are incremented by one if addresses are not the same, this is because the billing form has to be displayed
        if(!self.billingAddressSameAsDelivery && ![[ExersiteSession currentSession] isUserLoggedIn] && section == 1) {
            return @"Exersite Account";
        } else if((self.billingAddressSameAsDelivery && section == 1) || (!self.billingAddressSameAsDelivery && section == 2) || (!self.billingAddressSameAsDelivery && [[ExersiteSession currentSession] isUserLoggedIn] && section == 1)) {
            return @"Save address for future use?";
        }
    }
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(section == 0) {
        return nil;
    }
    
    CGSize sizeForHeaderTitle = [[self tableView:tableView titleForHeaderInSection:section] sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, roundf(sizeForHeaderTitle.height))];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    headerView.backgroundColor = RGBCOLOR(238, 238, 238);
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 0, self.frame.size.width - 16.0f, roundf(sizeForHeaderTitle.height))];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    headerLabel.textColor = RGBCOLOR(57, 58, 70);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.numberOfLines = 0;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [headerView addSubview:headerLabel];
    
    self.headerTopBorderLayer = [CALayer layer];
    _headerTopBorderLayer.backgroundColor = [RGBCOLOR(204, 204, 204) CGColor];
    _headerTopBorderLayer.frame = CGRectMake(0, 0, self.frame.size.width, 1.0f);
    [headerView.layer insertSublayer:_headerTopBorderLayer atIndex:100];
    
    self.headerBottomBorderLayer = [CALayer layer];
    _headerBottomBorderLayer.backgroundColor = [RGBCOLOR(204, 204, 204) CGColor];
    _headerBottomBorderLayer.frame = CGRectMake(0, sizeForHeaderTitle.height + 23.0f, self.frame.size.width, 1.0f);
    [headerView.layer insertSublayer:_headerBottomBorderLayer atIndex:100];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return 0;
    }
    
    CGSize sizeForHeaderTitle = [[self tableView:tableView titleForHeaderInSection:section] sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return roundf(sizeForHeaderTitle.height) + 24.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    
    // Explanation of this mess: if we're on the first page (ShopDeliveryScrollViewModeDeliveryAddress), this block always handles the first section
    
    // If we're on the second page (ShopDeliveryScrollViewModeBillingAddress), this block should handle section 0 if the user is not logged in, section 1 if the user is not logged in
    // and has specified their billing address is different from their delivery address (section 1 will be the Account registration form in this case), and will handle section 0
    // if the user is logged in and has a different billing/delivery address
    
    BOOL loggedIn = [[ExersiteSession currentSession] isUserLoggedIn]; // Local var for brevity
    
    if((indexPath.section == 0 && self.mode == ShopDeliveryScrollViewModeDeliveryAddress) ||
       (self.mode == ShopDeliveryScrollViewModeBillingAddress && ((!loggedIn && indexPath.section == 0) || (!loggedIn && !self.billingAddressSameAsDelivery && indexPath.section == 1) || (loggedIn && !self.billingAddressSameAsDelivery && indexPath.section == 0)) ))
    {
        
        NSString * fieldKey = nil;
        NSMutableArray * fieldsGroup = _fields;
        
        // Determine which form we should be showing
        if(self.mode == ShopDeliveryScrollViewModeDeliveryAddress) {
            fieldKey = kDeliveryFields[indexPath.row];
        } else {
            
            if(self.billingAddressSameAsDelivery) {
                fieldKey = kAccountFields[indexPath.row];
                fieldsGroup = _accountFields;
                
            } else {
                if(indexPath.section == 0) {
                    fieldKey = kBillingFields[indexPath.row];
                } else {
                    fieldKey = kAccountFields[indexPath.row];
                    fieldsGroup = _accountFields;
                }
            }
        }
        
        if([self _fieldForTag:indexPath.row inFieldsGroup:fieldsGroup]) {
            
            UITextField * fieldForCell = [self _fieldForTag:indexPath.row inFieldsGroup:fieldsGroup];
            [cell.contentView addSubview:fieldForCell];
            
        } else {
            
            UITextField * fieldForCell = [[UITextField alloc] initWithFrame:CGRectMake(8, 0, self.tableView.frame.size.width-16.0f, 44.0f)];
            fieldForCell.tag = indexPath.row;
            [cell.contentView addSubview:fieldForCell];
            
            NSString * placeholderForField = nil;
            
            if(fieldsGroup == _fields) {
                placeholderForField = kLabelText[indexPath.row];
            } else { // Account fields
                placeholderForField = kAccountLabelText[indexPath.row];
            }
            
            fieldForCell.placeholder = placeholderForField;
            
            fieldForCell.inputAccessoryView = self.fieldToolbar;
            fieldForCell.autocorrectionType = UITextAutocorrectionTypeNo;
            fieldForCell.delegate = self;
            
            fieldForCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            if(fieldsGroup == _accountFields && (indexPath.row == [kAccountFields indexOfObject:kAccountPassword] || indexPath.row == [kAccountFields indexOfObject:kAccountPasswordConfirmation])) {
                fieldForCell.secureTextEntry = YES;
            } else {
                fieldForCell.secureTextEntry = NO;
            }
            
            // Last field should have done button, which happens to be telephone in the delivery/billing form and confirm password in the account form
            if((fieldsGroup == _accountFields && fieldForCell.tag == [kAccountLabelText indexOfObject:kAccountPasswordConfirmation]) || (fieldsGroup != _accountFields && fieldForCell.tag == [kLabelText indexOfObject:@"Telephone"])) {
                fieldForCell.returnKeyType = UIReturnKeyDone;
            } else {
                fieldForCell.returnKeyType = UIReturnKeyNext;
            }
            
            // Items should have input-specific keyboard types
            if((fieldsGroup != _accountFields && fieldForCell.tag == [kLabelText indexOfObject:@"Email"]) || (fieldsGroup == _accountFields && fieldForCell.tag == [kAccountFields indexOfObject:kAccountEmail])) {
                fieldForCell.keyboardType = UIKeyboardTypeEmailAddress;
            } else if((fieldsGroup != _accountFields && fieldForCell.tag == [kLabelText indexOfObject:@"Telephone"])) {
                fieldForCell.keyboardType = UIKeyboardTypePhonePad;
            }
            
            fieldForCell.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            [fieldForCell addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            
            if([kDeliverySelectCells indexOfObject:fieldKey] != NSNotFound || [kBillingSelectCells indexOfObject:fieldKey] != NSNotFound) {
                fieldForCell.inputView = _pickerView;
            }
            
            [fieldsGroup addObject:fieldForCell];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
    } else {
        
        if(self.mode == ShopDeliveryScrollViewModeDeliveryAddress) {
            if(indexPath.row == 0) {
                cell.textLabel.text = @"Yes";
                
                if(_billingAddressSameAsDelivery) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else {
                cell.textLabel.text = @"No";
                
                if(!_billingAddressSameAsDelivery) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        } else {
            if(indexPath.row == 0) {
                cell.textLabel.text = @"Yes";
                
                if(_saveAddressForFutureUse) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else {
                cell.textLabel.text = @"No";
                
                if(!_saveAddressForFutureUse) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
    }
    
    return cell;
}

#pragma mark - Private Methods
+ (NSString*)titleStringWithMode:(ShopDeliveryScrollViewMode)mode billingAddressSameAsDelivery:(BOOL)billingAddressSameAsDelivery {
    
    NSString * titleString = nil;
    if(mode == ShopDeliveryScrollViewModeDeliveryAddress) {
        titleString = @"Delivery Address";
        
    } else {
        if(billingAddressSameAsDelivery) {
            if([[ExersiteSession currentSession] isUserLoggedIn]) {
                titleString = @"Save address for future use?";
            } else {
                titleString = @"Exersite Account";
            }
        } else {
            titleString = @"Billing Address";
        }
    }
    return titleString;
    
}

+ (NSString*)introductionStringWithMode:(ShopDeliveryScrollViewMode)mode billingAddressSameAsDelivery:(BOOL)billingAddressSameAsDelivery storedAddressesAvailable:(BOOL)storedAddressesAvailable {
    
    NSString * introductionString = nil;
    
    if(mode == ShopDeliveryScrollViewModeDeliveryAddress) {
        if(storedAddressesAvailable) {
            introductionString = kDeliveryStoredAddressesAvailable;
        } else {
            introductionString = kDeliveryInstructionsString;
        }
    } else {
        
        if(billingAddressSameAsDelivery) {
            if([[ExersiteSession currentSession] isUserLoggedIn]) {
                introductionString = kDeliverySaveAddressInstructionsString;
            } else {
                introductionString = kAccountInstructionsString;
            }
        } else {
            introductionString = @"Enter your billing address below. Tap 'Next Step' at the bottom of the page to continue to payment.";
        }
    }
    
    return introductionString;
}

- (void)didTapPreviousNextFormElement:(id)sender {
    
    NSInteger tagForField = _selectedField.tag;
    
    NSMutableArray * fieldsGroup = _fields;
    if([_fields indexOfObject:_selectedField] == NSNotFound && self.mode == ShopDeliveryScrollViewModeBillingAddress) {
        fieldsGroup = _accountFields;
    }
    
    LoginSegmentedControlButton * segmentedControl = (LoginSegmentedControlButton*)sender;
    LoginSegmentedControlButtonLastTouch lastTouch = segmentedControl.lastTouch;
    
    if(lastTouch == LoginSegmentedControlButtonLastTouchPrevious) {
        UITextField * textField = [self _fieldForTag:(tagForField - 1) inFieldsGroup:fieldsGroup];
        if(textField) {
            [textField becomeFirstResponder];
        }
        
    } else if(lastTouch == LoginSegmentedControlButtonLastTouchNext) {
        UITextField * textField = [self _fieldForTag:(tagForField + 1) inFieldsGroup:fieldsGroup];
        if(textField) {
            [textField becomeFirstResponder];
        }
    }
}

- (void)resignKeyboard:(id)sender {
    [_selectedField resignFirstResponder];
}

- (void)didTapChooseAddressButton:(id)sender {
    
    if([self.deliveryDelegate respondsToSelector:@selector(shopDeliveryScrollView:didTapChooseAddressButton:)]) {
        [self.deliveryDelegate performSelector:@selector(shopDeliveryScrollView:didTapChooseAddressButton:) withObject:self withObject:sender];
    }
}

- (void)didTapCreateNewAddressButton:(id)sender {
//    NSLog(@"didTapCreateNewAddressButton");
    
    self.createDeliveryAddressOptionsVisible = YES;
}

- (void)didTapNextStepButton:(id)sender {
//    NSLog(@"didTapNextStepButton");
    
    [self submitForm];
}

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)notification {
    
    if(!_keyboardTapGestureRecognizer) {
        self.keyboardTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOutOfKeyboard:)];
        [self addGestureRecognizer:self.keyboardTapGestureRecognizer];
    }
    
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    keyboardSize.height += 44.0f;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
    
    CGRect rect = self.frame;
    rect.size.height -= keyboardSize.height;
    
    CGPoint selectedTextFieldOrigin = self.selectedField.frame.origin;
    selectedTextFieldOrigin = [self.selectedField convertPoint:selectedTextFieldOrigin toView:nil]; // Convert to window coordinates
    
    if (!CGRectContainsPoint(rect, selectedTextFieldOrigin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, selectedTextFieldOrigin.y - keyboardSize.height + (44.0f + (self.contentOffset.y)));
        [self setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    
    if(_keyboardTapGestureRecognizer) {
        [self removeGestureRecognizer:self.keyboardTapGestureRecognizer];
        _keyboardTapGestureRecognizer = nil;
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
}

- (UITextField*)_fieldForTag:(NSInteger)tag inFieldsGroup:(NSArray*)fieldsGroup {
    
    NSPredicate * tagPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        UITextField * evaluatedTextField = (UITextField*)evaluatedObject;
        return (evaluatedTextField.tag == tag);
    }];
    NSArray * targetFieldArray = [fieldsGroup filteredArrayUsingPredicate:tagPredicate];
    if([targetFieldArray count] > 0) {
        return [targetFieldArray firstObject];
    } else {
        return nil;
    }
}

- (void)_recordFieldValue:(UITextField*)field {
    
    NSString * fieldLabel = nil;
    if(self.mode == ShopDeliveryScrollViewModeDeliveryAddress) {
        fieldLabel = kDeliveryFields[field.tag];
        
    } else { // self.mode == ShopDeliveryScrollViewModeBillingAddress
        
        if([_fields indexOfObject:_selectedField] == NSNotFound) { // Account field
            fieldLabel = kAccountFields[field.tag];
        } else {
            fieldLabel = kBillingFields[field.tag];
        }
    }
    
    // If the field selected's input method is UIPickerView, record value of item selected, instead of
    // user displayed title, ie instead of recording country title for the country picker, record the country code
    // as this is used internally, another example, for state record value/state index instead of state title
    // otherwise, just record exactly what the user input into the field
    
    if([_fields indexOfObject:_selectedField] != NSNotFound && field.tag == [kLabelText indexOfObject:@"Title"]) {
        
        NSInteger selectedTitleIndex = [kTitleOptions indexOfObject:field.text];
        _values[fieldLabel] = @(selectedTitleIndex);
        
        // Write display title according to current mode
        if(self.mode == ShopDeliveryScrollViewModeDeliveryAddress) {
            _values[kDeliveryTitleName] = kTitleOptions[selectedTitleIndex];
        } else {
            _values[kBillingTitleName] = kTitleOptions[selectedTitleIndex];
        }
        
    } else if([_fields indexOfObject:_selectedField] != NSNotFound && field.tag == [kLabelText indexOfObject:@"Country"]) {
        _values[fieldLabel] = _selectedCountry[@"code"];
        
        // Write display country according to current mode
        if(self.mode == ShopDeliveryScrollViewModeDeliveryAddress) {
            _values[kDeliveryCountryName] = _selectedCountry[@"title"];
        } else {
            _values[kBillingCountryName] = _selectedCountry[@"title"];
        }
        
    } else if([_fields indexOfObject:_selectedField] != NSNotFound && field.tag == [kLabelText indexOfObject:@"State"]) {
        
        NSString * stateDisplayKey = nil;
        if(self.mode == ShopDeliveryScrollViewModeDeliveryAddress) {
            stateDisplayKey = kDeliveryStateName;
        } else {
            stateDisplayKey = kBillingStateName;
        }
        
        if(_selectedState) {
            _values[fieldLabel] = _selectedState[@"code"];
            _values[stateDisplayKey] = _selectedState[@"title"];
            
        } else {
            field.text = @"N/A";
            _values[fieldLabel] = @"N/A";
            _values[stateDisplayKey] = @"N/A";
        }
        
    } else {
        _values[fieldLabel] = field.text;
    }
}

- (BOOL)_validateDeliveryBillingForm {
        
    NSString * missingFieldKey = nil;
    NSString * humanReadableNameForField = nil;
    
    for(NSString * requiredFieldKey in kDeliveryRequiredFields) {
        if(![[_values allKeys] containsObject:requiredFieldKey] || ([_values[requiredFieldKey] isKindOfClass:[NSString class]] && [_values[requiredFieldKey] length] == 0)) {
            missingFieldKey = requiredFieldKey;
            humanReadableNameForField = kLabelText[[kDeliveryFields indexOfObject:missingFieldKey]];
            break;
        }
    }
    
    // Next, validate email
    NSString * emailInput = (self.mode == ShopDeliveryScrollViewModeDeliveryAddress ? _values[kDeliveryEmail] : _values[kBillingEmail]);
    NSString * matchedEmailAddress = [emailInput stringByMatching:@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b" capture:1L];
    if(!matchedEmailAddress) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The email address entered is not valid. Please check your email address and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    
    if(missingFieldKey) {
        
        NSString * errorMessage = [NSString stringWithFormat:@"Please enter a response for '%@'. You must complete this field to continue.", humanReadableNameForField];
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)_validateAccountForm {
    
    // Firstly validate presence
    for(NSString * requiredFieldKey in kAccountRequiredFields) {
        if(![[_values allKeys] containsObject:requiredFieldKey] || ([_values[requiredFieldKey] isKindOfClass:[NSString class]] && [_values[requiredFieldKey] length] == 0)) {
            
            NSString * humanReadableNameForField = kAccountLabelText[[kAccountFields indexOfObject:requiredFieldKey]];
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"A value was not provided for '%@'. You must complete this field to continue.", humanReadableNameForField] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            return NO;
        }
    }
    
    // By this point, content in all fields is present, validate content, firstly verify password
    if(![_values[kAccountPassword] isEqualToString:_values[kAccountPasswordConfirmation]]) {
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your password and password confirmation do not match. Please fix this to continue." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    
    // Next, validate email
    NSString * matchedEmailAddress = [_values[kAccountEmail] stringByMatching:@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b" capture:1L];
    if(!matchedEmailAddress) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The email address entered is not valid. Please check your email address and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}

#pragma mark - Property Override
- (void)setBillingAddressSameAsDelivery:(BOOL)billingAddressSameAsDelivery {
    _billingAddressSameAsDelivery = billingAddressSameAsDelivery;
    
    _titleLabel.text = [[self class] titleStringWithMode:self.mode billingAddressSameAsDelivery:self.billingAddressSameAsDelivery];
    _introductionLabel.text = [[self class] introductionStringWithMode:self.mode billingAddressSameAsDelivery:self.billingAddressSameAsDelivery storedAddressesAvailable:self.storedAddressesAvailable];
    
    _values[kBillingDetailsSameAsDelivery] = @(billingAddressSameAsDelivery);
    
    if(_tableView) {
        [_tableView reloadData];
    }
    
    [self setNeedsLayout];
}

- (void)setStoredAddressesAvailable:(BOOL)storedAddressesAvailable {
    _storedAddressesAvailable = storedAddressesAvailable;
    
    if(storedAddressesAvailable) {
        
        _storedAddressChooseButton.hidden = NO;
        _createNewAddressButton.hidden = NO;
        _createNewAddressDescriptionLabel.hidden = NO;
        _storedAddressBorder.hidden = NO;
        
        self.createDeliveryAddressOptionsVisible = NO;
        
        _introductionLabel.text = kDeliveryStoredAddressesAvailable;
        
        [self.tableView reloadData];
        
        [self setNeedsLayout];
    }
}

- (void)setCreateDeliveryAddressOptionsVisible:(BOOL)createDeliveryAddressOptionsVisible {
    _createDeliveryAddressOptionsVisible = createDeliveryAddressOptionsVisible;
    
    if(createDeliveryAddressOptionsVisible) {
        _nextStepButton.hidden = NO;
        _createNewAddressButton.hidden = YES;
        
        [self.tableView beginUpdates];
        for(int i = 0; i < 2; i++) {
            for(int j = 0; j < [self tableView:_tableView numberOfRowsInSection:i]; j++) {
                [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:j inSection:i] ] withRowAnimation:UITableViewRowAnimationTop];
            }
        }
        [self.tableView endUpdates];
        
        
        
        [UIView animateWithDuration:0.5 animations:^{
            _tableView.frame = CGRectMake(0, _titleLabelBorder.frame.origin.y + _titleLabelBorder.frame.size.height, self.frame.size.width, ([kDeliveryFields count] * 44.0f) + (2 * 44.0f) + [self tableView:_tableView heightForHeaderInSection:1]);
        }];
        
    } else {
        
        _createNewAddressButton.hidden = NO;
        _nextStepButton.hidden = YES;
        [self.tableView reloadData];
    }
    
    // Display rows
    [self setNeedsLayout];
}

- (UIToolbar*)fieldToolbar {
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    
    toolbar.translucent = YES;
    toolbar.backgroundColor = [UIColor whiteColor];
    toolbar.tintColor = kTintColour;
    
    _toolbarBottomBorder = [CALayer layer];
    _toolbarBottomBorder.backgroundColor = [RGBCOLOR(204, 204, 204) CGColor];
    [toolbar.layer insertSublayer:_toolbarBottomBorder atIndex:100];
    
    LoginSegmentedControlButton * previousNextControl = [[LoginSegmentedControlButton alloc] initWithItems:@[ @"Previous", @"Next" ]];
    previousNextControl.tintColor = [UIColor grayColor];
    previousNextControl.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [previousNextControl addTarget:self action:@selector(didTapPreviousNextFormElement:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * previousNextItem = [[UIBarButtonItem alloc] initWithCustomView:previousNextControl];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard:)];
    
    [toolbar setItems:@[previousNextItem, flexButton, doneButton]];
    
    _fieldToolbar = toolbar;
    
    return _fieldToolbar;
}

#pragma mark - UIPickerViewDataSource Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if(_selectedField.tag == [kLabelText indexOfObject:@"Title"]) {
        return [kTitleOptions count];
        
    } else if(_selectedField.tag == [kLabelText indexOfObject:@"Country"]) {
        return [self.deliveryCountries count];
        
    } else {
        return [self.deliveryStates count];
    }
}

#pragma mark - UIPickerViewDelegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if(!_selectedField) return nil;
    
    if(_selectedField.tag == [kLabelText indexOfObject:@"Title"]) {
        return kTitleOptions[row];
        
    } else if(_selectedField.tag == [kLabelText indexOfObject:@"Country"]) {
        return self.deliveryCountries[row][@"title"];
        
    } else {
        return self.deliveryStates[row][@"title"];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if(!_selectedField) return;
    
    if(_selectedField.tag == [kLabelText indexOfObject:@"Title"]) {
        _selectedField.text = kTitleOptions[row];
        
    } else if(_selectedField.tag == [kLabelText indexOfObject:@"Country"]) {
        
        NSDictionary * countryDict = _deliveryCountries[row];
        _selectedField.text = countryDict[@"title"];
        _selectedCountry = countryDict;
        
    } else if(_selectedField.tag == [kLabelText indexOfObject:@"State"]) {
        
        // If the selected country actually has states to pick from
        if([_deliveryStates count] > 0) {
            
            NSDictionary * stateDict = _deliveryStates[row];
            _selectedField.text = stateDict[@"title"];
            _selectedState = stateDict;
            
        } else {
            _selectedState = @{ @"title": @"N/A" };
        }
    }
}

@end
