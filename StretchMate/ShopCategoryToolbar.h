//
//  ShopCategoryToolbar.h
//  Exersite
//
//  Created by James Eunson on 21/10/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopCategoryToolbarButton.h"

@protocol ShopCategoryToolbarDelegate;
@interface ShopCategoryToolbar : UIToolbar <UIScrollViewDelegate>

@property (nonatomic, strong) UIButton * searchButton;
@property (nonatomic, strong) UIScrollView * scrollView;

@property (nonatomic, strong) CALayer * separatorBorderLayer;
@property (nonatomic, strong) CALayer * bottomBorderLayer;

@property (nonatomic, strong) NSMutableArray * buttons;
@property (nonatomic, assign) NSInteger selectedButtonIndex;

@property (nonatomic, assign) __unsafe_unretained id<ShopCategoryToolbarDelegate> categoryToolbarDelegate;

- (void)addButton:(ShopCategoryToolbarButton*)button;
- (void)selectButtonAtIndex:(NSInteger)index shouldNotifyDelegate:(BOOL)shouldNotifyDelegate animated:(BOOL)animated;

- (void)clearState;

@end

@protocol ShopCategoryToolbarDelegate <NSObject>
- (void)shopCategoryToolbar:(ShopCategoryToolbar*)toolbar didChangeToCategoryAtIndex:(NSNumber*)index;
- (void)shopCategoryToolbar:(ShopCategoryToolbar*)toolbar didTapSearchButton:(UIButton*)button;
@end