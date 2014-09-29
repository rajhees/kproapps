//
//  ShopCartScrollView.h
//  Exersite
//
//  Created by James Eunson on 5/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopBigButton.h"
#import "ShopCartTableView.h"

@protocol ShopCartScrollViewDelegate;
@interface ShopCartScrollView : UIScrollView <ShopCartTableViewDelegate>

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * itemsCountLabel;

@property (nonatomic, strong) ShopCartTableView * cartItemsTableView;
@property (nonatomic, strong) CALayer * cartItemsTableViewTopBorder;
@property (nonatomic, strong) CALayer * cartItemsTableViewBottomBorder;

@property (nonatomic, strong) ShopBigButton * checkoutButton;

@property (nonatomic, strong) UILabel * deliveringOutsideAustraliaTitleLabel;
@property (nonatomic, strong) CALayer * deliveringOutsideAustraliaBorderLayer;
@property (nonatomic, strong) UILabel * deliveringOutsideAustraliaBodyLabel;

@property (nonatomic, strong) ShopBigButton * requestQuoteButton;

@property (nonatomic, strong) UIImageView * emptyViewImageView;
@property (nonatomic, strong) UILabel * emptyViewTitleLabel;
@property (nonatomic, strong) UILabel * emptyViewSubtitleLabel;

@property (nonatomic, assign) __unsafe_unretained id<ShopCartScrollViewDelegate> cartDelegate;

- (void)updateContent;
+ (CGFloat)containerHeightForCartScrollView;

@end

@protocol ShopCartScrollViewDelegate<NSObject>
- (void)shopCartScrollView:(ShopCartScrollView*)detailScrollView didSelectCartItem:(NSDictionary*)cartItem;
- (void)shopCartScrollView:(ShopCartScrollView*)detailScrollView didTapCheckoutButton:(ShopBigButton*)button;
- (void)shopCartScrollView:(ShopCartScrollView*)detailScrollView didTapRequestQuoteButton:(ShopBigButton*)button;
- (void)shopCartScrollView:(ShopCartScrollView *)detailScrollView didRemoveCartItemFromTableView:(UITableView*)tableView;
@end
