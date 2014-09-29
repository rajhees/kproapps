//
//  ShopConfirmOrderViewController.h
//  Exersite
//
//  Created by James Eunson on 19/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopConfirmOrderScrollView.h"

@interface ShopConfirmOrderViewController : UIViewController <ShopConfirmOrderScrollViewDelegate>

@property (nonatomic, strong) ShopConfirmOrderScrollView * scrollView;

@property (nonatomic, strong) NSString * stripeToken;
@property (nonatomic, strong) NSDictionary * selectedAddress;

@property (nonatomic, strong) NSNumber * internationalShippingAmount;

@end
