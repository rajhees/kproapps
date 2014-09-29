//
//  LoginButtonCell.h
//  StretchMate
//
//  Created by James Eunson on 6/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LoginButtonCellTypeLogin,
    LoginButtonCellTypeRegister,
    LoginButtonCellTypeConfirmRegistration,
    LoginButtonCellTypeResetPassword,
    LoginButtonCellTypeCheckoutAsGuest
} LoginButtonCellType;

@interface LoginButtonCell : UITableViewCell

@property (nonatomic, strong) UIView * buttonBackgroundView;
@property (nonatomic, strong) UIView * buttonHighlightedView;

@property (nonatomic, strong) UIImageView * buttonHighlightedBackgroundView;
@property (nonatomic, assign) LoginButtonCellType type;

@end
