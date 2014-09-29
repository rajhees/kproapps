//
//  ShopCartViewController.h
//  Exersite
//
//  Created by James Eunson on 22/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopCartScrollView.h"
#import "LoginCheckoutViewController.h"

@interface ShopCartViewController : UIViewController <ShopCartScrollViewDelegate, LoginControllerDelegate>

@property (nonatomic, strong) ShopCartScrollView * scrollView;
@property (nonatomic, assign, getter = isEditing) BOOL editing;

@end
