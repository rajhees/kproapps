//
//  ShopDetailScrollView.h
//  StretchMate
//
//  Created by James Eunson on 6/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopItem.h"
#import "ShopBigButton.h"

@protocol ShopDetailScrollViewDelegate;
@interface ShopDetailScrollView : UIScrollView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) UIButton * subtitleButton;
@property (nonatomic, strong) UILabel * subtitleLabel;
@property (nonatomic, strong) UIImageView * subtitleArrowImageView;

@property (nonatomic, strong) UILabel * priceLabel;

@property (nonatomic, strong) UIView * priceLabelContainerView;

@property (nonatomic, strong) UIView * itemImageContainerView;
@property (nonatomic, strong) UIActivityIndicatorView * itemImageLoadingView;
@property (nonatomic, strong) UIImageView * itemImageView;
@property (nonatomic, strong) UIButton * itemImageZoomButton;

@property (nonatomic, strong) UILabel * shippingDetailsLabel;
@property (nonatomic, strong) UIButton * requestQuoteButton;

@property (nonatomic, strong) CALayer * descriptionSeparatorBorderLayer;
@property (nonatomic, strong) UILabel * descriptionTitleLabel;
@property (nonatomic, strong) UILabel * descriptionBodyLabel;

@property (nonatomic, strong) CALayer * relatedSeparatorBorderLayer;
@property (nonatomic, strong) UILabel * relatedTitleLabel;
@property (nonatomic, strong) UIButton * relatedTextButton;
@property (nonatomic, strong) UICollectionView * relatedCollectionView;
@property (nonatomic, strong) NSMutableArray * relatedItems;

@property (nonatomic, strong) ShopBigButton * addToCartButton;

@property (nonatomic, assign) __unsafe_unretained id<ShopDetailScrollViewDelegate> shopDelegate;
//@property (nonatomic, strong) ShopItem * selectedItem;
@property (nonatomic, strong) NSDictionary * selectedItem;

+ (CGFloat)containerHeightWithSelectedItem:(NSDictionary*)item;

@end

@protocol ShopDetailScrollViewDelegate <NSObject>
- (void)shopDetailScrollView:(ShopDetailScrollView*)detailScrollView didAddProductToCart:(NSDictionary*)product;
- (void)shopDetailScrollView:(ShopDetailScrollView*)detailScrollView didTapSubtitleButtonWithProduct:(NSDictionary*)product;
- (void)shopDetailScrollView:(ShopDetailScrollView*)detailScrollView didZoomImageWithProduct:(NSDictionary*)product;
- (void)shopDetailScrollView:(ShopDetailScrollView*)detailScrollView didTapRequestQuoteButtonWithProduct:(NSDictionary*)product;
- (void)shopDetailScrollView:(ShopDetailScrollView*)detailScrollView didTapViewRelatedButtonWithProduct:(NSDictionary*)product;
- (void)shopDetailScrollView:(ShopDetailScrollView *)detailScrollView didSelectRelatedProduct:(NSDictionary*)product;
@end