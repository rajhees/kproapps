//
//  ShopConfirmOrderViewController.m
//  Exersite
//
//  Created by James Eunson on 19/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopConfirmOrderViewController.h"
#import "ExersiteHTTPClient.h"
#import "ShopDeliveryScrollView.h"
#import "ProgressHUDHelper.h"
#import "ShopOrderCompleteViewController.h"
#import "UIAlertView+Blocks.h"

@interface ShopConfirmOrderViewController ()

@property (nonatomic, strong) ExersiteHTTPClient * httpClient;

- (void)_createOrder;

@end

@implementation ShopConfirmOrderViewController

- (id)init {
    self = [super init];
    if(self) {
        self.httpClient = [[ExersiteHTTPClient alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail-stripes-bg"]];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    }
    
    self.scrollView = [[ShopConfirmOrderScrollView alloc] init];
    
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.selectedAddress = self.selectedAddress;
    _scrollView.internationalShippingAmount = self.internationalShippingAmount;
    _scrollView.confirmDelegate = self;
    
    [self.view addSubview:_scrollView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_scrollView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Confirm Order";
}

#pragma mark - ShopConfirmOrderScrollViewDelegate Methods
- (void)shopConfirmOrderScrollView:(ShopConfirmOrderScrollView *)scrollView didTapConfirmOrderButton:(ShopBigButton *)button {
//    NSLog(@"shopConfirmOrderScrollView:didTapConfirmOrderButton:");
    
    RIButtonItem * confirmItem = [RIButtonItem itemWithLabel:@"Confirm"];
    
    NSNumber * cartAmount = nil;
    if(self.internationalShippingAmount) {
        cartAmount = @([[AppConfig sharedConfig] shopCartSubtotal] + [_internationalShippingAmount doubleValue]);
    } else {
        cartAmount = @([[AppConfig sharedConfig] shopCartSubtotal] + 10);
    }
    
    NSString * confirmMessage = [NSString stringWithFormat:@"Are you sure you want to place this order? Your card will be charged for A$%.2f.", [cartAmount doubleValue]];
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Order?" message:confirmMessage cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems:confirmItem, nil];
    [alertView show];
    
    confirmItem.action = ^{
        [self _createOrder];
    };
}

#pragma mark - Private Methods
- (void)_createOrder {
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
    
    NSString * shopCartJson = [[AppConfig sharedConfig] shopCartItemsJson];
    NSMutableDictionary * orderParameters = [@{ @"stripe_token": self.stripeToken, @"shop_cart_items": shopCartJson } mutableCopy];
    
    // If identifier is present, address is stored on the server and should only be identified
    if([[self.selectedAddress allKeys] containsObject:kAddressIdentifier]) {
        orderParameters[kAddressIdentifier] = self.selectedAddress[kAddressIdentifier];
    } else {
     
        // Remove display values from address
        NSMutableDictionary * mutableSelectedAddress = [self.selectedAddress mutableCopy];
        NSArray * displayFields = [[[NSMutableArray alloc] initWithArray:kDeliveryDisplayFields] arrayByAddingObjectsFromArray:kBillingDisplayFields];
        for(NSString * deliveryDisplayField in displayFields) {
            if([[mutableSelectedAddress allKeys] containsObject:deliveryDisplayField]) {
//                NSLog(@"removing %@", deliveryDisplayField);
                [mutableSelectedAddress removeObjectForKey:deliveryDisplayField];
            }
        }
        orderParameters[@"address"] = mutableSelectedAddress;
    }
    
    // Determine total order cost, to charge card with
    double orderSubtotalCents = [[AppConfig sharedConfig] shopCartSubtotal] * 100.00;
    orderParameters[@"order_subtotal"] = @(orderSubtotalCents);
    
    if(self.internationalShippingAmount) {
        
        NSNumber * shopCartTotalWithInternationalShipping = @([[AppConfig sharedConfig] shopCartSubtotal] + [_internationalShippingAmount doubleValue]);
        
        double orderTotalCents = ([shopCartTotalWithInternationalShipping doubleValue] * 100.00);
        orderParameters[@"order_total"] = [@(orderTotalCents) stringValue];
        
        double shippingCents = ([self.internationalShippingAmount doubleValue] * 100.00);
        orderParameters[@"shipping"] = [@(shippingCents) stringValue];
        
    } else {
        
        double orderTotalCents = ([@([[AppConfig sharedConfig] shopCartSubtotal] + 10) doubleValue] * 100.00);
        orderParameters[@"order_total"] = [@(orderTotalCents) stringValue];
    }
    
    [_httpClient createNewOrderWithParameters:orderParameters completion:^(NSDictionary *result) {
        
        if([result[@"success"] isEqualToString:@"true"]) {
            
            [loadingView hide:YES];
            
            ShopOrderCompleteViewController * controller = [[ShopOrderCompleteViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            
        } else {
            
            NSString * errorMessage = nil;
            
            if([[result allKeys] containsObject:@"errors"] && [result[@"errors"] isKindOfClass:[NSArray class]] && [result[@"errors"] count] > 0) {
                NSArray * errors = result[@"errors"];
                errorMessage = [errors firstObject];
            }
            
            if(!errorMessage) {
                errorMessage = @"An error has occurred while trying to process your order. Please try again later. If this continues, please contact support.";
            }
            
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

@end
