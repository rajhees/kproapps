//
//  ShopConfirmOrderScrollView.h
//  Exersite
//
//  Created by James Eunson on 19/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopCartTableView.h"
#import "ShopCheckoutStepView.h"
#import "ShopBigButton.h"

@protocol ShopConfirmOrderScrollViewDelegate;
@interface ShopConfirmOrderScrollView : UIScrollView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSDictionary * selectedAddress;
@property (nonatomic, strong) NSNumber * internationalShippingAmount;

@property (nonatomic, strong) ShopCheckoutStepView * stepView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * introductionLabel;

@property (nonatomic, strong) ShopCartTableView * cartItemsTableView;
@property (nonatomic, strong) CALayer * cartItemsTopBorderLayer;

@property (nonatomic, strong) UILabel * addressTitleLabel;
@property (nonatomic, strong) CALayer * addressTableTopBorderLayer;
@property (nonatomic, strong) UITableView * addressTableView;

@property (nonatomic, strong) UILabel * paymentMethodTitleLabel;
@property (nonatomic, strong) UILabel * paymentMethodLabel;

@property (nonatomic, strong) ShopBigButton * confirmOrderButton;

@property (nonatomic, assign) __unsafe_unretained id<ShopConfirmOrderScrollViewDelegate> confirmDelegate;

+ (CGFloat)heightForScrollViewWithSelectedAddress:(NSDictionary*)selectedAddress;

@end

@protocol ShopConfirmOrderScrollViewDelegate <NSObject>
@required
- (void)shopConfirmOrderScrollView:(ShopConfirmOrderScrollView*)scrollView didTapConfirmOrderButton:(ShopBigButton*)button;
@end