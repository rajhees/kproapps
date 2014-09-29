//
//  ShopAddToCartButton.h
//  Exersite
//
//  Created by James Eunson on 26/10/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ShopBigButtonTypeAddToCart,
    ShopBigButtonTypeItemInCart,
    ShopBigButtonTypeCheckoutNow,
    ShopBigButtonTypeRequestDeliveryQuote,
    ShopBigButtonTypeRequestDeliveryQuoteConfirm,
    ShopBigButtonTypeNextStep,
    ShopBigButtonTypeChooseAddress,
    ShopBigButtonTypeCreateNewAddress,
    ShopBigButtonTypeConfirmOrder,
    ShopBigButtonTypeOKGotIt,
} ShopBigButtonType;

@interface ShopBigButton : UIButton

@property (nonatomic, strong) UILabel *addToCartLabel;
@property (nonatomic, strong) UIView * addToCartBackgroundView;

@property (nonatomic, assign) ShopBigButtonType type;

@end
