//
//  ShopConfirmOrderScrollView.m
//  Exersite
//
//  Created by James Eunson on 19/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopConfirmOrderScrollView.h"
#import "ShopStoredAddressCell.h"
#import "ShopDeliveryScrollView.h"

#define kCellReuseIdentifier @"storedAddressCell"

#define kTitleText @"Confirm Order"
#define kIntroductionText @"Please review your order items, delivery and billing address and payment method. If all is correct, please press the Confirm Order button at the bottom of the page to complete your order."

#define kAddressTitleText @"Selected Address"
#define kPaymentMethodTitleText @"Payment Method"
#define kPaymentMethodCreditCardText @"Credit Card"

@interface ShopConfirmOrderScrollView ()
- (void)didTapConfirmOrderButton:(id)sender;
@end

@implementation ShopConfirmOrderScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.stepView = [[ShopCheckoutStepView alloc] init];
        _stepView.selectedStep = ShopCheckoutStepConfirm;
        [self addSubview:_stepView];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = RGBCOLOR(57, 58, 70);
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = kTitleText;
        [self addSubview:_titleLabel];
        
        self.introductionLabel = [[UILabel alloc] init];
        _introductionLabel.text = kIntroductionText;
        _introductionLabel.font = [UIFont systemFontOfSize:13.0f];
        _introductionLabel.textColor = RGBCOLOR(99, 100, 109);
        _introductionLabel.backgroundColor = [UIColor clearColor];
        _introductionLabel.numberOfLines = 0;
        _introductionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_introductionLabel];
        
        self.cartItemsTopBorderLayer = [CALayer layer];
        _cartItemsTopBorderLayer.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_cartItemsTopBorderLayer atIndex:100];
        
        self.cartItemsTableView = [[ShopCartTableView alloc] init];
        [self addSubview:_cartItemsTableView];
        
        self.addressTitleLabel = [[UILabel alloc] init];
        _addressTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _addressTitleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _addressTitleLabel.backgroundColor = [UIColor clearColor];
        _addressTitleLabel.numberOfLines = 0;
        _addressTitleLabel.text = kAddressTitleText;
        [self addSubview:_addressTitleLabel];
        
        self.addressTableTopBorderLayer = [CALayer layer];
        _addressTableTopBorderLayer.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
        [self.layer insertSublayer:_addressTableTopBorderLayer atIndex:100];
        
        self.addressTableView = [[UITableView alloc] init];
        _addressTableView.delegate = self;
        _addressTableView.dataSource = self;
        _addressTableView.backgroundColor = RGBCOLOR(238, 238, 238);
        _addressTableView.separatorInset = UIEdgeInsetsZero;
        [_addressTableView registerClass:[ShopStoredAddressCell class] forCellReuseIdentifier:kCellReuseIdentifier];
        [self addSubview:_addressTableView];
        
        self.paymentMethodTitleLabel = [[UILabel alloc] init];
        _paymentMethodTitleLabel.textColor = RGBCOLOR(57, 58, 70);
        _paymentMethodTitleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _paymentMethodTitleLabel.backgroundColor = [UIColor clearColor];
        _paymentMethodTitleLabel.numberOfLines = 0;
        _paymentMethodTitleLabel.text = kPaymentMethodTitleText;
        [self addSubview:_paymentMethodTitleLabel];
        
        self.paymentMethodLabel = [[UILabel alloc] init];
        _paymentMethodLabel.text = kPaymentMethodCreditCardText;
        _paymentMethodLabel.font = [UIFont systemFontOfSize:13.0f];
        _paymentMethodLabel.textColor = RGBCOLOR(99, 100, 109);
        _paymentMethodLabel.backgroundColor = [UIColor clearColor];
        _paymentMethodLabel.numberOfLines = 0;
        _paymentMethodLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_paymentMethodLabel];
        
        self.confirmOrderButton = [[ShopBigButton alloc] init];
        _confirmOrderButton.type = ShopBigButtonTypeConfirmOrder;
        [_confirmOrderButton addTarget:self action:@selector(didTapConfirmOrderButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_confirmOrderButton];
        
        [self setNeedsLayout];
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
    
    _cartItemsTopBorderLayer.frame = CGRectMake(0, _introductionLabel.frame.origin.y + _introductionLabel.frame.size.height + 18.0f, self.frame.size.width, 1.0f);
    
    CGFloat heightForTableView = [ShopCartTableView heightForTableView];
    self.cartItemsTableView.frame = CGRectMake(0, _introductionLabel.frame.origin.y + _introductionLabel.frame.size.height + 19.0f, self.frame.size.width, heightForTableView);
    
    CGSize sizeForAddressTitleLabel = [_addressTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    self.addressTitleLabel.frame = CGRectMake(8, _cartItemsTableView.frame.origin.y + _cartItemsTableView.frame.size.height + 18.0f, sizeForAddressTitleLabel.width, sizeForAddressTitleLabel.height);
    
    _addressTableTopBorderLayer.frame = CGRectMake(0, _addressTitleLabel.frame.origin.y + _addressTitleLabel.frame.size.height + 8.0f, self.frame.size.width, 1.0f);
    
    CGFloat heightForAddressTableView = [ShopStoredAddressCell heightForCellWithStoredAddress:_selectedAddress displayingOnPaymentPage:YES];
    _addressTableView.frame = CGRectMake(0, _addressTitleLabel.frame.origin.y + _addressTitleLabel.frame.size.height + 9.0f, self.frame.size.width, heightForAddressTableView);
    
    CGSize sizeForPaymentMethodTitleLabel = [_paymentMethodTitleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    self.paymentMethodTitleLabel.frame = CGRectMake(8, _addressTableView.frame.origin.y + _addressTableView.frame.size.height + 18.0f, sizeForPaymentMethodTitleLabel.width, sizeForPaymentMethodTitleLabel.height);
    
    CGSize sizeForPaymentMethodLabel = [self.paymentMethodLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.frame.size.width - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.paymentMethodLabel.frame = CGRectMake(8, _paymentMethodTitleLabel.frame.origin.y + _paymentMethodTitleLabel.frame.size.height + 8.0f, sizeForPaymentMethodLabel.width, sizeForPaymentMethodLabel.height);
    
    _confirmOrderButton.frame = CGRectMake(8.0f, _paymentMethodLabel.frame.origin.y + _paymentMethodLabel.frame.size.height + 20.0f, self.frame.size.width - 16.0f, 44.0f);
    
    self.contentSize = CGSizeMake(self.frame.size.width, [[self class] heightForScrollViewWithSelectedAddress:_selectedAddress]);
}

+ (CGFloat)heightForScrollViewWithSelectedAddress:(NSDictionary*)selectedAddress {
    
    CGFloat screenWidth = -1.0f;
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.height;
    } else {
        screenWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    }
    
    CGFloat heightAccumulator = 33.0f; // Base value is step indicator
    
    heightAccumulator += (12.0f + [kTitleText sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]].height);
    heightAccumulator += (8.0f + [kIntroductionText sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height);
    
    heightAccumulator += (19.0f + [ShopCartTableView heightForTableView]);
    
    CGSize sizeForAddressTitleLabel = [kAddressTitleText sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]];
    heightAccumulator += (19.0f + sizeForAddressTitleLabel.height);
    
    heightAccumulator += (8.0f + [ShopStoredAddressCell heightForCellWithStoredAddress:selectedAddress displayingOnPaymentPage:YES]);
    
    heightAccumulator += (19.0f + [kPaymentMethodTitleText sizeWithFont:[UIFont boldSystemFontOfSize:18.0f]].height + 8.0f + [kPaymentMethodCreditCardText sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(screenWidth - 16.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20.0f + 44.0f + 20.0f);
    
    return heightAccumulator;
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShopStoredAddressCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    
    cell.storedAddress = _selectedAddress;
    cell.selectedAddress = YES;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ShopStoredAddressCell heightForCellWithStoredAddress:_selectedAddress displayingOnPaymentPage:YES];
}

#pragma mark - Property Override
- (void)setInternationalShippingAmount:(NSNumber *)internationalShippingAmount {
    _internationalShippingAmount = internationalShippingAmount;
    
    if(self.internationalShippingAmount) {
        
        _cartItemsTableView.internationalShippingAmount = self.internationalShippingAmount;
        _cartItemsTableView.internationalShippingCountry = self.selectedAddress[kDeliveryCountryName];
        
        [_cartItemsTableView reloadData];
        [self setNeedsLayout];
    }
}

#pragma mark - Private Methods
- (void)didTapConfirmOrderButton:(id)sender {
    
//    NSLog(@"didTapConfirmOrderButton:");
    
    if([self.confirmDelegate respondsToSelector:@selector(shopConfirmOrderScrollView:didTapConfirmOrderButton:)]) {
        [self.confirmDelegate performSelector:@selector(shopConfirmOrderScrollView:didTapConfirmOrderButton:) withObject:self withObject:sender];
    }
}

@end
