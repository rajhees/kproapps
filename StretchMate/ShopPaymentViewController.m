//
//  ShopCheckoutViewController.m
//  Exersite
//
//  Created by James Eunson on 6/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopDeliveryScrollView.h"
#import "ShopPaymentViewController.h"
#import "UIAlertView+Blocks.h"
#import "ShopRequestQuoteViewController.h"
#import "AppDelegate.h"
#import "ExersiteDrawerController.h"
#import "RegexKitLite.h"
#import "ShopConfirmOrderViewController.h"

@interface ShopPaymentViewController ()

@property (nonatomic, strong) NSNumber * internationalShippingAmount;

- (void)_displayInternationalDeliveryAlertViewWithPreviousError:(BOOL)previousError;

@end

@implementation ShopPaymentViewController

- (void)loadView {
    [super loadView];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail-stripes-bg"]];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    }
    
    self.scrollView = [[ShopPaymentScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.selectedAddress = self.selectedAddress;
    _scrollView.paymentDelegate = self;
    [self.view addSubview:_scrollView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_scrollView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Payment";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(![self.selectedAddress[kDeliveryCountry] isEqualToString:@"AU"]) {
        [self _displayInternationalDeliveryAlertViewWithPreviousError:NO];
        
    } else {
        
        double shopCartTotalWithinAustralia = [[AppConfig sharedConfig] shopCartSubtotal] + 10;
        
        self.scrollView.orderTotalLabel.text = [NSString stringWithFormat:kOrderTotalTemplateText, shopCartTotalWithinAustralia, [[AppConfig sharedConfig] shopCartSubtotal], 10.0];
        [self.scrollView setNeedsLayout];
    }
}

#pragma mark - Private Methods
- (void)_displayInternationalDeliveryAlertViewWithPreviousError:(BOOL)previousError {
    
    RIButtonItem * requestQuoteItem = [RIButtonItem itemWithLabel:@"Request Quote"];
    RIButtonItem * confirmItem = [RIButtonItem itemWithLabel:@"Confirm Amount"];
    RIButtonItem * cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
    
    NSString * alertViewMessage = nil;
    if(previousError) {
        alertViewMessage = @"The amount you entered previously was invalid. Please ensure it is in the format XX.XX. No currency sign (eg. $) is required.";
    } else {
        alertViewMessage = @"You have specified a delivery address outside of Australia. Please input the amount of shipping you have been instructed to pay in the field below in form XX.XX. If you have not requested a quote for shipping to your country, please do so using the Request Quote button below.";
    }
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Add International Shipping" message:alertViewMessage cancelButtonItem:cancelItem otherButtonItems: confirmItem, requestQuoteItem, nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].placeholder = @"XX.XX";
    [alertView show];
    
    // This is required, because otherwise the Stripe form immediately grabs first responder
    // which is not cool if we need the user to input international shipping information first
    [[alertView textFieldAtIndex:0] becomeFirstResponder];
    
    requestQuoteItem.action = ^{
        [self dismissViewControllerAnimated:YES completion:^{
            
            // Get the shop navigation controller the long way round
            AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            ExersiteDrawerController * drawerController = (ExersiteDrawerController*)delegate.window.rootViewController;
            UINavigationController * shopNavigationController = drawerController.shopNavigationController;
            
            ShopRequestQuoteViewController * controller = [[ShopRequestQuoteViewController alloc] init];
            UINavigationController * modalNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            [shopNavigationController presentViewController:modalNavigationController animated:YES completion:nil];
        }];
    };
    
    cancelItem.action = ^{
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    confirmItem.action = ^{
        NSString * amountString = [[alertView textFieldAtIndex:0] text];
        
        // Validate amount
        NSString * validatedAmount = [amountString stringByMatching:@"^([0-9]{2}\\.[0-9]{2})"];
        
        // Can't cancel the removal of the UIAlertView without some fancy overriding, display it again, this time with an error message
        if(!validatedAmount) {
            [self _displayInternationalDeliveryAlertViewWithPreviousError:YES];
            
        } else { // Amount was valid, parse into NSNumber, and display in label above STPView
            
            self.internationalShippingAmount = @([validatedAmount doubleValue]);
            NSNumber * shopCartTotalWithInternationalShipping = @([[AppConfig sharedConfig] shopCartSubtotal] + [_internationalShippingAmount doubleValue]);
            
            self.scrollView.orderTotalLabel.text = [NSString stringWithFormat:kOrderTotalTemplateText,
                                                    [shopCartTotalWithInternationalShipping doubleValue], [[AppConfig sharedConfig] shopCartSubtotal], [_internationalShippingAmount doubleValue]];
            [self.scrollView setNeedsLayout];
        }
    };
}

#pragma mark - ShopPaymentScrollViewDelegate Methods
- (void)shopPaymentScrollView:(ShopPaymentScrollView*)shopPaymentScrollView didReceiveToken:(NSString*)token {
//    NSLog(@"shopPaymentScrollView:didReceiveToken:");
    
    ShopConfirmOrderViewController * controller = [[ShopConfirmOrderViewController alloc] init];
    
    controller.stripeToken = token;
    controller.selectedAddress = _selectedAddress;
    
    if(self.internationalShippingAmount) {
        controller.internationalShippingAmount = self.internationalShippingAmount;
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
