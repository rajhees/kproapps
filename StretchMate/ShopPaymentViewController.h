//
//  ShopCheckoutViewController.h
//  Exersite
//
//  Created by James Eunson on 6/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopPaymentScrollView.h"

@interface ShopPaymentViewController : UIViewController <ShopPaymentScrollViewDelegate>

@property (nonatomic, strong) ShopPaymentScrollView * scrollView;
@property (nonatomic, strong) NSDictionary * selectedAddress;

@end
