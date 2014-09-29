//
//  ShopRequestQuoteScrollView.m
//  Exersite
//
//  Created by James Eunson on 6/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopRequestQuoteScrollView.h"
#import "ShopRequestQuoteFieldCell.h"
#import "LoginSegmentedControlButton.h"

#define kFieldCellReuseIdentifier @"fieldCell"

#define kFieldTagDeliveryCountry 887
#define kFieldTagEmail 888

// Note about this view, I'm pretty much resigned to the fact that any form will include
// significant repetition without doing some probably inefficient work genericizing everything
// Note that much of this code is pulled from LoginBaseViewController and reworked for this context
@interface ShopRequestQuoteScrollView ()

- (void)textFieldDidChange:(id)sender;
- (void)resignKeyboard:(id)sender;
- (void)didTapPreviousNextFormElement:(id)sender;

- (void)registerForKeyboardNotifications;
- (void)unregisterKeyboardNotifications;
- (void)keyboardWasShown:(NSNotification*)notification;
- (void)keyboardWillBeHidden:(NSNotification*)notification;

- (void)didTapOutOfKeyboard:(id)sender;
- (void)didTapRequestQuoteButton:(id)sender;

@property (nonatomic, strong) UIPickerView * deliveryCountryPickerView;

@property (nonatomic, strong, readonly) UITextField * deliveryCountryTextField;
@property (nonatomic, strong, readonly) UITextField * emailTextField;

@property (nonatomic, strong) UITextField * selectedTextField;
@property (nonatomic, strong) UITapGestureRecognizer * keyboardTapGestureRecognizer;

@property (nonatomic, strong) CALayer * toolbarBottomBorder;

@end

@implementation ShopRequestQuoteScrollView

@synthesize fieldToolbar = _fieldToolbar;
@synthesize deliveryCountryTextField = _deliveryCountryTextField;
@synthesize emailTextField = _emailTextField;

- (void)dealloc {
    [self unregisterKeyboardNotifications];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.deliveryCountries = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor clearColor];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = RGBCOLOR(57, 58, 70);
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.text = @"Request a quote for International Delivery";
        [self addSubview:_titleLabel];
        
        self.titleBorder = [CALayer layer];
        [_titleBorder setBackgroundColor:RGBCOLOR(221, 221, 221).CGColor];
        [self.layer addSublayer:_titleBorder];

        self.requestQuoteBodyLabel = [[UILabel alloc] init];
        _requestQuoteBodyLabel.font = [UIFont systemFontOfSize:13.0f];
        _requestQuoteBodyLabel.textColor = RGBCOLOR(99, 100, 109);
        _requestQuoteBodyLabel.backgroundColor = [UIColor clearColor];
        _requestQuoteBodyLabel.numberOfLines = 0;
        _requestQuoteBodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _requestQuoteBodyLabel.text = @"You are requesting a quote for the following items. If these are not the items you wish to get a delivery quote for, please place the correct items in your cart.\n\nWe will endeavour to respond to shipping requests within 48 hours. Please ensure your spam filter has not caught the response.";
        [self addSubview:_requestQuoteBodyLabel];
        
        self.cartItemsTableViewTopBorder = [CALayer layer];
        [_cartItemsTableViewTopBorder setBackgroundColor:RGBCOLOR(221, 221, 221).CGColor];
        [self.layer addSublayer:_cartItemsTableViewTopBorder];
        
        self.cartItemsTableView = [[ShopCartTableView alloc] initWithType:ShopCartTableViewTypeRequestQuote];
        [self addSubview:_cartItemsTableView];
        
        self.cartItemsEmptyMessageLabel = [[UILabel alloc] init];
        _cartItemsEmptyMessageLabel.font = [UIFont systemFontOfSize:14.0f];
        _cartItemsEmptyMessageLabel.textColor = [UIColor grayColor];
        _cartItemsEmptyMessageLabel.backgroundColor = [UIColor clearColor];
        _cartItemsEmptyMessageLabel.numberOfLines = 0;
        _cartItemsEmptyMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _cartItemsEmptyMessageLabel.text = @"You have no items in your cart. Please add the items to your cart that you wish to get a quote on delivery for.";
        _cartItemsEmptyMessageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_cartItemsEmptyMessageLabel];
        
        self.cartItemsEmptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-request-quote-empty-icon-ios7"]];
        [self addSubview:_cartItemsEmptyImageView];
        
        self.enterYourDetailsLabel = [[UILabel alloc] init];
        _enterYourDetailsLabel.textColor = RGBCOLOR(57, 58, 70);
        _enterYourDetailsLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _enterYourDetailsLabel.backgroundColor = [UIColor clearColor];
        _enterYourDetailsLabel.numberOfLines = 0;
        _enterYourDetailsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _enterYourDetailsLabel.text = @"Enter your details";
        [self addSubview:_enterYourDetailsLabel];
        
        self.enterYourDetailsBorder = [CALayer layer];
        [_enterYourDetailsBorder setBackgroundColor:RGBCOLOR(221, 221, 221).CGColor];
        [self.layer addSublayer:_enterYourDetailsBorder];
        
        self.enterYourDetailsTableView = [[UITableView alloc] init];
        _enterYourDetailsTableView.delegate = self;
        _enterYourDetailsTableView.dataSource = self;
        [_enterYourDetailsTableView registerClass:[ShopRequestQuoteFieldCell class] forCellReuseIdentifier:kFieldCellReuseIdentifier];
        
        _enterYourDetailsTableView.separatorInset = UIEdgeInsetsZero;
        [self addSubview:_enterYourDetailsTableView];
        
        self.requestQuoteButton = [[ShopBigButton alloc] init];
        _requestQuoteButton.type = ShopBigButtonTypeRequestDeliveryQuoteConfirm;
        [_requestQuoteButton addTarget:self action:@selector(didTapRequestQuoteButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_requestQuoteButton];
        
        if([[[AppConfig sharedConfig] shopCartItems] count] == 0) {
            _cartItemsTableView.hidden = YES;
            _cartItemsEmptyMessageLabel.hidden = NO;
            _cartItemsEmptyImageView.hidden = NO;
            _enterYourDetailsLabel.hidden = YES;
            _enterYourDetailsBorder.hidden = YES;
            _enterYourDetailsTableView.hidden = YES;
            _requestQuoteButton.hidden = YES;
            
        } else {
            _cartItemsTableView.hidden = NO;
            _cartItemsEmptyMessageLabel.hidden = YES;
            _cartItemsEmptyImageView.hidden = YES;
            _enterYourDetailsLabel.hidden = NO;
            _enterYourDetailsBorder.hidden = NO;
            _enterYourDetailsTableView.hidden = NO;
            _requestQuoteButton.hidden = NO;
        }
        
        self.deliveryCountryPickerView = [[UIPickerView alloc] init];
        _deliveryCountryPickerView.delegate = self;
        _deliveryCountryPickerView.dataSource = self;
        
        self.requestDetails = [[NSMutableDictionary alloc] init];
        
        [self registerForKeyboardNotifications];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeForTitleLabel = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX)];
    self.titleLabel.frame = CGRectMake(8, 12, sizeForTitleLabel.width, sizeForTitleLabel.height);
    
    [_titleBorder setFrame:CGRectMake(0, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 8.0f, self.frame.size.width, 1)];
    
    CGSize sizeForRequestQuoteBodyLabel = [self.requestQuoteBodyLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX)];
    self.requestQuoteBodyLabel.frame = CGRectMake(8.0f, _titleBorder.frame.origin.y + _titleBorder.frame.size.height + 8.0f, sizeForRequestQuoteBodyLabel.width, sizeForRequestQuoteBodyLabel.height);
    
    [_cartItemsTableViewTopBorder setFrame:CGRectMake(0, _requestQuoteBodyLabel.frame.origin.y + _requestQuoteBodyLabel.frame.size.height + 19.0f, self.frame.size.width, 1)];
    
    self.cartItemsTableView.frame = CGRectMake(0, _requestQuoteBodyLabel.frame.origin.y + _requestQuoteBodyLabel.frame.size.height + 20.0f, self.frame.size.width, [ShopCartTableView heightForTableView]);
    
    CGFloat constrainedSizeForEmptyMessageLabel = ((self.frame.size.width / 8) * 6);
    CGSize sizeForItemsEmptyMessageLabel = [self.cartItemsEmptyMessageLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(constrainedSizeForEmptyMessageLabel, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat cartEmptyViewHeight = (self.frame.size.height - (_requestQuoteBodyLabel.frame.origin.y + _requestQuoteBodyLabel.frame.size.height + 19.0f));
    
    self.cartItemsEmptyImageView.frame = CGRectMake((self.frame.size.width / 2) - (_cartItemsEmptyImageView.frame.size.width / 2), _requestQuoteBodyLabel.frame.origin.y + _requestQuoteBodyLabel.frame.size.height + (cartEmptyViewHeight / 2) - ((_cartItemsEmptyImageView.frame.size.height + sizeForItemsEmptyMessageLabel.height + 8.0f) / 2), _cartItemsEmptyImageView.frame.size.width, _cartItemsEmptyImageView.frame.size.height);
    
    self.cartItemsEmptyMessageLabel.frame = CGRectMake((self.frame.size.width / 8), _cartItemsEmptyImageView.frame.origin.y + _cartItemsEmptyImageView.frame.size.height + 8.0f, constrainedSizeForEmptyMessageLabel, sizeForItemsEmptyMessageLabel.height);
    
    CGSize sizeForEnterYourDetailsLabel = [self.enterYourDetailsLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX)];
    self.enterYourDetailsLabel.frame = CGRectMake(8, _cartItemsTableView.frame.origin.y + _cartItemsTableView.frame.size.height + 20.0f, sizeForEnterYourDetailsLabel.width, sizeForEnterYourDetailsLabel.height);
    [_enterYourDetailsBorder setFrame:CGRectMake(0, _enterYourDetailsLabel.frame.origin.y + _enterYourDetailsLabel.frame.size.height + 8.0f, self.frame.size.width, 1)];
    
    self.enterYourDetailsTableView.frame = CGRectMake(0, _enterYourDetailsBorder.frame.origin.y + _enterYourDetailsBorder.frame.size.height, self.frame.size.width, 88.0f);
    
    self.requestQuoteButton.frame = CGRectMake(8.0f, _enterYourDetailsTableView.frame.origin.y + _enterYourDetailsTableView.frame.size.height + 8.0f, self.frame.size.width - 16.0f, 44.0f);
}

+ (CGFloat)heightForScrollView {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGFloat heightAccumulator = 0;
    
    CGSize sizeForTitleLabel = [@"Request a quote for International Delivery" sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX)];
    heightAccumulator += (12.0f + sizeForTitleLabel.height + 8.0f);
    
    CGSize sizeForRequestQuoteBodyLabel = [@"You are requesting a quote for the following items. If these are not the items you wish to get a delivery quote for, please place the correct items in your cart.\n\nWe will endeavour to respond to shipping requests within 48 hours. Please ensure your spam filter has not caught the response." sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX)];
    heightAccumulator += (1.0f + 8.0f + sizeForRequestQuoteBodyLabel.height); // Includes border
    
    // View is laid out differently depending on whether cart items are visible or not
    if([[[AppConfig sharedConfig] shopCartItems] count] > 0) {
        
        CGFloat tableViewHeight = [ShopCartTableView heightForTableView];
        heightAccumulator += (19.0f + 1.0f + 8.0f + tableViewHeight);
        
        CGSize sizeForEnterYourDetailsLabel = [@"Enter your details" sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX)];
        heightAccumulator += sizeForEnterYourDetailsLabel.height + 20.0f + 1.0f + 88.0f + 44.0f + 8.0f + 40.0f; // Includes border
        
    }
    
    return roundf(heightAccumulator);
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShopRequestQuoteFieldCell * cell = [tableView dequeueReusableCellWithIdentifier:kFieldCellReuseIdentifier forIndexPath:indexPath];
    
    if(indexPath.row == 0) {
        [cell addSubview:self.deliveryCountryTextField];
    } else {
        [cell addSubview:self.emailTextField];
    }
    
    return cell;
}

#pragma mark - UITextFieldDelegate Methods
- (void)textFieldDidChange:(id)sender {
    if(_selectedTextField == _emailTextField) {
        _requestDetails[kRequestDetailsEmailKey] = _emailTextField.text;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _selectedTextField = textField;
    
    UIToolbar * fieldToolbar = (UIToolbar*)self.selectedTextField.inputAccessoryView;
    UIBarButtonItem * segmentedControlButtonItem = (UIBarButtonItem*)[fieldToolbar.items firstObject];
    LoginSegmentedControlButton * previousNextControl = (LoginSegmentedControlButton *)segmentedControlButtonItem.customView;
    
    [previousNextControl setEnabled:YES forSegmentAtIndex:0];
    [previousNextControl setEnabled:YES forSegmentAtIndex:1];
    
    if(_selectedTextField == _deliveryCountryTextField) {
        
        [previousNextControl setEnabled:NO forSegmentAtIndex:0];
        [previousNextControl setEnabled:YES forSegmentAtIndex:1];
        
    } else if(_selectedTextField == _emailTextField) {
        
        [previousNextControl setEnabled:YES forSegmentAtIndex:0];
        [previousNextControl setEnabled:NO forSegmentAtIndex:1];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Property Override
// TODO: Fix code duplication from LoginBaseViewController and this
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

- (UITextField*)deliveryCountryTextField {
    
    if(_deliveryCountryTextField) {
        return _deliveryCountryTextField;
    }
    
    _deliveryCountryTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0f, 0, self.frame.size.width - 16.0f, 44.0f)];
    _deliveryCountryTextField.backgroundColor = [UIColor clearColor];
    _deliveryCountryTextField.font = [UIFont systemFontOfSize:18.0f];
    _deliveryCountryTextField.returnKeyType = UIReturnKeyDone;
    _deliveryCountryTextField.delegate = self;
    _deliveryCountryTextField.inputView = _deliveryCountryPickerView;
    _deliveryCountryTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _deliveryCountryTextField.inputAccessoryView = self.fieldToolbar;
    
    _deliveryCountryTextField.placeholder = @"Delivery Country";
    _deliveryCountryTextField.tag = kFieldTagDeliveryCountry;
    
    return _deliveryCountryTextField;
}

- (UITextField*)emailTextField {
    
    if(_emailTextField) {
        return _emailTextField;
    }
    
    _emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(8.0f, 0, self.frame.size.width - 16.0f, 44.0f)];
    _emailTextField.backgroundColor = [UIColor clearColor];
    _emailTextField.font = [UIFont systemFontOfSize:18.0f];
    _emailTextField.returnKeyType = UIReturnKeyDone;
    _emailTextField.delegate = self;
    _emailTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _emailTextField.inputAccessoryView = self.fieldToolbar;
    
    _emailTextField.placeholder = @"Email";
    _emailTextField.tag = kFieldTagEmail;
    _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [_emailTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    return _emailTextField;
}

#pragma mark - Private Methods
- (void)resignKeyboard:(id)sender {
    [_deliveryCountryTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
}

- (void)didTapPreviousNextFormElement:(id)sender {
//    NSLog(@"didTapPreviousNextFormElement");
    
    LoginSegmentedControlButton * segmentedControl = (LoginSegmentedControlButton*)sender;
    LoginSegmentedControlButtonLastTouch lastTouch = segmentedControl.lastTouch;
    
    if(lastTouch == LoginSegmentedControlButtonLastTouchPrevious) {
        if(_selectedTextField == _emailTextField) {
            [_deliveryCountryTextField becomeFirstResponder];
        }
        
    } else if(lastTouch == LoginSegmentedControlButtonLastTouchNext) {
        if(_selectedTextField == _deliveryCountryTextField) {
            [_emailTextField becomeFirstResponder];
        }
    }
}

- (void)didTapOutOfKeyboard:(id)sender {
    [self.selectedTextField resignFirstResponder];
}

- (void)didTapRequestQuoteButton:(id)sender {
    
    if([self.requestQuoteDelegate respondsToSelector:@selector(shopRequestQuoteScrollView:didTapSubmitButton:)]) {
        [self.requestQuoteDelegate performSelector:@selector(shopRequestQuoteScrollView:didTapSubmitButton:) withObject:self withObject:sender];
    }
}

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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
    
    CGPoint selectedTextFieldOrigin = self.selectedTextField.frame.origin;
    selectedTextFieldOrigin = [self.selectedTextField convertPoint:selectedTextFieldOrigin toView:nil]; // Convert to window coordinates
    
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

#pragma mark - UIPickerViewDataSource Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.deliveryCountries count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSDictionary * countryDict = _deliveryCountries[row];
    return countryDict[@"title"];
}

#pragma mark - UIPickerViewDelegate Methods
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    NSLog(@"didTapPickerView: %@", _deliveryCountries[row]);
    
    NSDictionary * countryDict = _deliveryCountries[row];
    _deliveryCountryTextField.text = countryDict[@"title"];
    
    _requestDetails[kRequestDetailsDeliveryCountryKey] = countryDict[@"title"];
    _requestDetails[kRequestDetailsDeliveryCountryCodeKey] = countryDict[@"code"];
}

@end
