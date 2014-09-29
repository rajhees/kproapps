//
//  ShopCheckoutStepView.h
//  Exersite
//
//  Created by James Eunson on 11/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ShopCheckoutStepLogin,
    ShopCheckoutStepDelivery,
    ShopCheckoutStepPayment,
    ShopCheckoutStepConfirm,
} ShopCheckoutStep;

@interface ShopCheckoutStepView : UIView

@property (nonatomic, strong) CALayer * bottomBorderLayer;
@property (nonatomic, assign) ShopCheckoutStep selectedStep;

@end
