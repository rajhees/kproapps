//
//  ShopRequestQuoteViewController.m
//  Exersite
//
//  Created by James Eunson on 21/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopRequestQuoteViewController.h"
#import "ExersiteHTTPClient.h"
#import "ProgressHUDHelper.h"
#import "UIAlertView+Blocks.h"

@interface ShopRequestQuoteViewController ()

- (void)confirmRequestWithRequestDetails:(NSDictionary*)details;

@end

@implementation ShopRequestQuoteViewController

- (void)loadView {
    [super loadView];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail-stripes-bg"]];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    }
    
    self.scrollView = [[ShopRequestQuoteScrollView alloc] init];
    
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [ShopRequestQuoteScrollView heightForScrollView]);
    _scrollView.requestQuoteDelegate = self;
    
    [self.view addSubview:_scrollView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_scrollView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Request a Quote";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewControllerAnimated:)];
    
    // No need to load this unless the user actually has items in their cart 
    if([[[AppConfig sharedConfig] shopCartItems] count] > 0) {
        MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
        
        ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
        [httpClient retrieveDeliveryCountriesForRequestQuote:^(NSArray * countries) {
            
            [_scrollView.deliveryCountries addObjectsFromArray:countries];
            [loadingView hide:YES];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ShopRequestQuoteScrollViewDelegate
- (void)shopRequestQuoteScrollView:(ShopRequestQuoteScrollView*)shopRequestQuoteScrollView didTapSubmitButton:(ShopBigButton*)submitButton {
    
    NSDictionary * requestDetails = shopRequestQuoteScrollView.requestDetails;
    
    if([[requestDetails allKeys] count] == 3 && [requestDetails[kRequestDetailsEmailKey] length] > 0
       && [requestDetails[kRequestDetailsDeliveryCountryKey] length] > 0 && [requestDetails[kRequestDetailsDeliveryCountryCodeKey] length] > 0) {
        
        NSInteger cartItemCount = [[[AppConfig sharedConfig] shopCartItems] count];
        NSString * itemsPluralized = (cartItemCount == 1 ? @"item" : @"items");
        
        NSString * deliveryCountry = requestDetails[kRequestDetailsDeliveryCountryKey];
        NSString * email = requestDetails[kRequestDetailsEmailKey];
        
        NSString * confirmMessage = [NSString stringWithFormat:@"You are sending a quote request for %d %@, delivered to %@. You will be contacted at %@. Is this correct?", cartItemCount, itemsPluralized, deliveryCountry, email];
        
        RIButtonItem * confirmButton = [RIButtonItem itemWithLabel:@"Confirm"];
        confirmButton.action = ^{
            [self confirmRequestWithRequestDetails:requestDetails];
        };
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Confirm Request" message:confirmMessage cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems: confirmButton, nil];
        [alertView show];
        
    } else {
        NSString * errorMessage = nil;
        
        if(![[requestDetails allKeys] containsObject:kRequestDetailsDeliveryCountryCodeKey] || ![[requestDetails allKeys] containsObject:kRequestDetailsDeliveryCountryKey] || [requestDetails[kRequestDetailsDeliveryCountryCodeKey] length] == 0 || [requestDetails[kRequestDetailsDeliveryCountryKey] length] == 0) {
            errorMessage = @"Please select your delivery country.";
        } else if(![[requestDetails allKeys] containsObject:kRequestDetailsEmailKey] || [requestDetails[kRequestDetailsEmailKey] length] == 0) {
            errorMessage = @"Please enter your contact email.";
        }
        if(errorMessage) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }
}

#pragma mark - Private Methods
- (void)confirmRequestWithRequestDetails:(NSDictionary*)details {
    
//    NSLog(@"request quote confirm");
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
    
    ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
    [httpClient submitRequestQuoteWithParameters:details completion:^(NSDictionary *result) {
        [loadingView hide:YES];
        
        if(!result || ([[result allKeys] containsObject:@"success"] && ![result[@"success"] boolValue])) {
            
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occurred while submitting your request. Please check the form for correctness and try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        
        RIButtonItem * okButton = [RIButtonItem itemWithLabel:@"OK"];
        okButton.action = ^{
            if([self.navigationController.viewControllers count] == 1) { // Modal
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        };
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your request has been submitted. Please allow 48 hours for a response. Be sure to check your spam filter to ensure the response has not been caught." cancelButtonItem:nil otherButtonItems:okButton, nil];
        [alertView show];
    }];
}

@end
