//
//  ShopShippingInformationHeaderView.h
//  Exersite
//
//  Created by James Eunson on 21/10/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShopShippingInformationHeaderDelegate;
@interface ShopShippingInformationHeaderView : UIView

@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic, strong) UIImageView * iconImageView;

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * subtitleLabel;

@property (nonatomic, strong) UILabel * requestQuoteButtonLabel;
@property (nonatomic, strong) UIImageView * requestQuoteButtonImageView;
@property (nonatomic, strong) UIButton * requestQuoteButton;

@property (nonatomic, assign) __unsafe_unretained id<ShopShippingInformationHeaderDelegate> delegate;

@end

@protocol ShopShippingInformationHeaderDelegate <NSObject>
- (void)shopShippingInformationHeader:(ShopShippingInformationHeaderView*)headerView didSelectRequestQuoteButton:(UIButton*)button;
@end
