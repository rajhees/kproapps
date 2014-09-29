//
//  ShopOrderDetailViewController.h
//  Exersite
//
//  Created by James Eunson on 20/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopOrderDetailScrollView.h"

@interface ShopOrderDetailViewController : UIViewController

@property (nonatomic, strong) ShopOrderDetailScrollView * scrollView;
@property (nonatomic, strong) NSDictionary * selectedOrder;

@end
