//
//  ShopDeliveryViewController.h
//  Exersite
//
//  Created by James Eunson on 11/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopDeliveryScrollView.h"
#import "ShopChooseStoredAddressViewController.h"

typedef enum {
    ShopDeliveryViewControllerModeDeliveryAddress,
    ShopDeliveryViewControllerModeBillingAddress
} ShopDeliveryViewControllerMode;

@interface ShopDeliveryViewController : UIViewController <ShopDeliveryScrollViewDelegate, ShopChooseStoredAddressViewControllerDelegate>

@property (nonatomic, strong) ShopDeliveryScrollView * scrollView;
@property (nonatomic, assign) ShopDeliveryViewControllerMode mode;

@property (nonatomic, assign) BOOL billingAddressSameAsDelivery;

// Used to pass values from the delivery stage to the billing stage, pretty hackish, could probably do this better
@property (nonatomic, strong) NSDictionary * previousControllerValues;

@end
