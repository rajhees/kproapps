//
//  LoginRegisterDetailsViewController.h
//  Exersite
//
//  Created by James Eunson on 4/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginBaseViewController.h"

@interface LoginRegisterDetailsViewController : LoginBaseViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSDictionary * serverResponseDict;
@property (nonatomic, strong) NSDictionary * invitationDetailsDict;

@end
