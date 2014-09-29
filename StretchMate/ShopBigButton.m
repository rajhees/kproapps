//
//  ShopAddToCartButton.m
//  Exersite
//
//  Created by James Eunson on 26/10/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopBigButton.h"

@implementation ShopBigButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.addToCartBackgroundView = [[UIView alloc] init];
        
        _addToCartBackgroundView.backgroundColor = kTintColour;
        _addToCartBackgroundView.layer.cornerRadius = 4.0f;
        
        _addToCartBackgroundView.userInteractionEnabled = NO;
        
        [self addSubview:_addToCartBackgroundView];
        
        self.addToCartLabel = [[UILabel alloc] init];
        
        _addToCartLabel.backgroundColor = [UIColor clearColor];
        _addToCartLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _addToCartLabel.textColor = [UIColor whiteColor];
        _addToCartLabel.textAlignment = NSTextAlignmentCenter;
        
        _addToCartLabel.userInteractionEnabled = NO;
        
        [self addSubview:_addToCartLabel];
    }
    return self;
}

- (void)setType:(ShopBigButtonType)type {
    _type = type;
    
    if(type == ShopBigButtonTypeAddToCart) {
        
        _addToCartLabel.text = @"Add to Cart";
        _addToCartBackgroundView.backgroundColor = kTintColour;
        
    } else if(type == ShopBigButtonTypeCheckoutNow) {
        
        _addToCartLabel.text = @"Checkout Now";
        _addToCartBackgroundView.backgroundColor = kTintColour;
        
    } else if(type == ShopBigButtonTypeRequestDeliveryQuote) {
        
        _addToCartLabel.text = @"Request a Delivery Quote";
        _addToCartBackgroundView.backgroundColor = RGBCOLOR(165, 166, 171);
        
    } else if(type == ShopBigButtonTypeItemInCart) {
        
        _addToCartLabel.text = @"Item in Cart";
        _addToCartBackgroundView.backgroundColor = kFadedTintColour;
        
    } else if(type == ShopBigButtonTypeRequestDeliveryQuoteConfirm) {
        
        _addToCartLabel.text = @"Request a Delivery Quote";
        _addToCartBackgroundView.backgroundColor = kTintColour;
        
    } else if(type == ShopBigButtonTypeNextStep) {
        
        _addToCartLabel.text = @"Next Step";
        _addToCartBackgroundView.backgroundColor = kTintColour;
        
    } else if(type == ShopBigButtonTypeChooseAddress) {
        
        _addToCartLabel.text = @"Choose Stored Address";
        _addToCartBackgroundView.backgroundColor = kTintColour;
        
    } else if(type == ShopBigButtonTypeCreateNewAddress) {
        
        _addToCartLabel.text = @"Create New Address";
        _addToCartBackgroundView.backgroundColor = RGBCOLOR(165, 166, 171);
        
    } else if(type == ShopBigButtonTypeConfirmOrder) {
        
        _addToCartLabel.text = @"Confirm Order";
        _addToCartBackgroundView.backgroundColor = kTintColour;
        
    } else if(type == ShopBigButtonTypeOKGotIt) {
        
        _addToCartLabel.text = @"Ok, got it";
        _addToCartBackgroundView.backgroundColor = RGBCOLOR(165, 166, 171);
        
    } else if(type == ShopBigButtonTypeConfirmOrder) {
        
        _addToCartLabel.text = @"Confirm Order";
        _addToCartBackgroundView.backgroundColor = kTintColour;
        
    } else if(type == ShopBigButtonTypeOKGotIt) {
        
        _addToCartLabel.text = @"Ok, got it";
        _addToCartBackgroundView.backgroundColor = RGBCOLOR(165, 166, 171);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _addToCartBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _addToCartLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

@end
