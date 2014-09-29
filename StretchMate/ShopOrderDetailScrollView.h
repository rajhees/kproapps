//
//  ShopOrderDetailScrollView.h
//  Exersite
//
//  Created by James Eunson on 20/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopCartTableView.h"

@interface ShopOrderDetailScrollView : UIScrollView <UITableViewDataSource, UITableViewDelegate, ShopCartTableViewDelegate>

@property (nonatomic, strong) NSDictionary * order;

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * introductionLabel;
@property (nonatomic, strong) CALayer * cartItemsTableViewTopBorder;

@property (nonatomic, strong) ShopCartTableView * cartItemsTableView;

@property (nonatomic, strong) UILabel * addressTitleLabel;
@property (nonatomic, strong) CALayer * addressTableViewTopBorder;
@property (nonatomic, strong) UITableView * addressTableView;

- (id)initWithOrder:(NSDictionary*)order;

+ (CGFloat)heightForScrollViewWithOrder:(NSDictionary*)order;

@end
