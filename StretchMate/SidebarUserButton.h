//
//  SidebarUserButton.h
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kUserButtonWidth 210.f

typedef enum {
    UserStateNoUser,
    UserStateLoggedIn
} UserState;

@interface SidebarUserButton : UIButton

@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * roleLabel;

@property (nonatomic, strong) UIView * imagePlaceholderView;

@property (nonatomic, strong) UIImageView * userPortraitImageView;

- (void)updateUserInformation;
- (void)deselectUserButton;

@end
