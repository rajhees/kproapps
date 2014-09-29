//
//  LoginViewController.h
//  StretchMate
//
//  Created by James Eunson on 27/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginBaseViewController.h"

static NSString * kLoginButtonCellIdentifier = @"loginButtonCell";

@protocol LoginControllerDelegate;
@interface LoginViewController : LoginBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign) __unsafe_unretained id<LoginControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * cancelItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * doneItem;

@property (nonatomic, strong) UIView * footerContainerView;

@property (nonatomic, assign) BOOL shouldAuthenticateUsingSavedCredentials;

- (void)startAuthentication;

@end

@protocol LoginControllerDelegate <NSObject>
@required
- (void)loginViewControllerDidLogin:(LoginViewController*)controller;

@optional
- (void)loginViewControllerLoginDidFail:(LoginViewController*)controller;
@end