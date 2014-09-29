//
//  ShopCartOrdersToolbar.h
//  Exersite
//
//  Created by James Eunson on 22/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShopCartOrdersDelegate;
@interface ShopCartOrdersToolbar : UIToolbar

@property (nonatomic, assign) __unsafe_unretained id<ShopCartOrdersDelegate> cartOrdersDelegate;
@property (nonatomic, strong) UIView * cartBadgeView;

- (void)updateCartValue;

@end


@protocol ShopCartOrdersDelegate <NSObject>
- (void)shopCartOrdersToolbar:(ShopCartOrdersToolbar*)toolbar didTapOrdersButton:(UIButton*)button;
- (void)shopCartOrdersToolbar:(ShopCartOrdersToolbar*)toolbar didTapCartButton:(UIButton*)button;
@end