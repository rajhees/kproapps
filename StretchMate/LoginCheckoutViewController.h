//
//  LoginCheckoutViewController.h
//  Exersite
//
//  Created by James Eunson on 11/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "ShopCheckoutStepView.h"

@interface LoginCheckoutViewController : LoginViewController

@property (nonatomic, strong) ShopCheckoutStepView * stepView;

@end
