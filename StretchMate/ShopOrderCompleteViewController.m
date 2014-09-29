//
//  ShopOrderCompleteViewController.m
//  Exersite
//
//  Created by James Eunson on 19/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopOrderCompleteViewController.h"

@interface ShopOrderCompleteViewController ()

@end

@implementation ShopOrderCompleteViewController

- (void)loadView {
    [super loadView];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail-stripes-bg"]];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    }
    
    self.scrollView = [[ShopOrderCompleteScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.orderCompleteDelegate = self;
    
    [self.view addSubview:_scrollView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_scrollView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Order Complete";
    
    // User going back would be extremely bad at this point (eg. repeated card charges, headaches for everyone)
    self.navigationItem.hidesBackButton = YES;
    
    // Clear cart
    for(NSDictionary * shopCartItem in [[AppConfig sharedConfig] shopCartItems]) {
        [[AppConfig sharedConfig] removeShopCartItem:shopCartItem];
    }
}

#pragma mark - ShopOrderCompleteScrollViewDelegate Methods
- (void)shopOrderCompleteScrollView:(ShopOrderCompleteScrollView*)scrollView didTapOkButton:(ShopBigButton*)button {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
