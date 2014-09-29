//
//  ShopPaymentScrollView.h
//  Exersite
//
//  Created by James Eunson on 12/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STPView.h"
#import "ShopCartTableView.h"
#import "ShopCheckoutStepView.h"
#import "ShopBigButton.h"

#define kOrderTotalTemplateText @"Order Total: A$%.2f (A$%.2f + A$%.2f shipping)"

@protocol ShopPaymentScrollViewDelegate;
@interface ShopPaymentScrollView : UIScrollView <STPViewDelegate>

@property (nonatomic, strong) NSDictionary * selectedAddress;

@property (nonatomic, strong) ShopCheckoutStepView * stepView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * introductionLabel;
@property (nonatomic, strong) UILabel * orderTotalLabel;

@property (nonatomic, strong) STPView * stripeView;
@property (nonatomic, strong) ShopBigButton * nextStepButton;

@property (nonatomic, assign) __unsafe_unretained id<ShopPaymentScrollViewDelegate> paymentDelegate;

+ (CGFloat)heightForScrollViewWithSelectedAddress:(NSDictionary*)selectedAddress;

@end

@protocol ShopPaymentScrollViewDelegate <NSObject>
@required
- (void)shopPaymentScrollView:(ShopPaymentScrollView*)shopPaymentScrollView didReceiveToken:(NSString*)token;
@end