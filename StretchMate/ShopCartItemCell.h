//
//  ShopCartItemCell.h
//  Exersite
//
//  Created by James Eunson on 5/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopCartItemCell : UITableViewCell

@property (nonatomic, strong) NSDictionary * cartItemDict;

@property (nonatomic, strong) UILabel * itemTitleLabel;
@property (nonatomic, strong) UILabel * qtyLabel;
@property (nonatomic, strong) UILabel * priceLabel;
@property (nonatomic, strong) UILabel * subtitleLabel;

@property (nonatomic, strong) UIView * cartItemImageContainerView;
@property (nonatomic, strong) UIImageView * cartItemImageView;

+ (CGFloat)heightForCellWithCartItem:(NSDictionary*)cartItem;

@end
