//
//  ShopViewController.h
//  StretchMate
//
//  Created by James Eunson on 3/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopCategoryToolbar.h"
#import "ShopShippingInformationHeaderView.h"
#import "ShopCartOrdersToolbar.h"
#import "LoginViewController.h"

typedef enum {
    ShopViewControllerModeNormal,
    ShopViewControllerModeCategory
} ShopViewControllerMode;

@interface ShopViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ShopCategoryToolbarDelegate, UIScrollViewDelegate, ShopShippingInformationHeaderDelegate, ShopCartOrdersDelegate, LoginControllerDelegate>

@property (nonatomic, strong) UIScrollView * contentScrollView;
@property (nonatomic, strong) UIView * containerView;

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSArray * categoryCollectionViews;

@property (nonatomic, strong) NSArray * items;
@property (nonatomic, strong) NSArray * categories;

// Category mode only properties
@property (nonatomic, assign) ShopViewControllerMode mode;
//@property (nonatomic, strong) NSString * selectedCategoryTitle;
//@property (nonatomic, strong) NSString * selectedCategorySlug;
@property (nonatomic, strong) NSDictionary * selectedCategoryItem;
@property (nonatomic, strong) UICollectionView * selectedCategoryCollectionView;

//@property (nonatomic, strong) UIToolbar * toolbar;
@property (nonatomic, strong) ShopCartOrdersToolbar * toolbar;
@property (nonatomic, strong) ShopCategoryToolbar * categoryToolbar;
@property (nonatomic, strong) ShopShippingInformationHeaderView * headerView;

@end
