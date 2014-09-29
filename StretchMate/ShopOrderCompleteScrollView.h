//
//  ShopOrderCompleteScrollView.h
//  Exersite
//
//  Created by James Eunson on 20/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopBigButton.h"

@protocol ShopOrderCompleteScrollViewDelegate;
@interface ShopOrderCompleteScrollView : UIScrollView

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * bodyMessageLabel;

@property (nonatomic, strong) UIImageView * completeImageView;

@property (nonatomic, strong) ShopBigButton * okBigButton;

@property (nonatomic, assign) __unsafe_unretained id<ShopOrderCompleteScrollViewDelegate> orderCompleteDelegate;

+ (CGFloat)heightForScrollView;

@end

@protocol ShopOrderCompleteScrollViewDelegate <NSObject>
@required
- (void)shopOrderCompleteScrollView:(ShopOrderCompleteScrollView*)scrollView didTapOkButton:(ShopBigButton*)button;
@end
