//
//  ShopBuyButton.h
//  StretchMate
//
//  Created by James Eunson on 6/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BuyButtonStateNormal,
    BuyButtonStateAwaitingConfirmation,
    BuyButtonStateConfirmed
} BuyButtonState;

@interface ShopBuyButton : UIButton

- (id)initWithFrame:(CGRect)frame price:(NSString*)priceString;
+ (CGFloat)widthForPrice:(NSString*)priceString;

@property (nonatomic, strong) UIView * shadeView;
@property (nonatomic, assign) BuyButtonState currentState;
@property (nonatomic, strong) UILabel * priceLabel;
@property (nonatomic, strong) UIView * buyContainerView;
@property (nonatomic, strong) NSString * priceString;
@property (nonatomic, strong) UIImageView * buyIconView;

@end
