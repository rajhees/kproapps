//
//  LoginBaseViewController.h
//  Exersite
//
//  Created by James Eunson on 3/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginRegisterHeaderView.h"
#import "ExersiteHTTPClient.h"
#import "UIViewController+KeyboardNotifications.h"

static CGFloat textFieldHeight = 23.0f;

@interface LoginBaseViewController : UIViewController

@property (nonatomic, strong) UIScrollView * scrollView;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UIView * tableViewBackgroundView;
@property (nonatomic, strong) UIImageView * tableBottomDarkenOverlay;

@property (nonatomic, strong) LoginRegisterHeaderView * headerView;

@property (nonatomic, strong) UIImageView * invitationNoticeBackgroundImageView;
@property (nonatomic, strong, readonly) UILabel * invitationNoticeLabel;

@property (nonatomic, strong, readonly) UIToolbar * fieldToolbar;

@property (nonatomic, strong, readonly) UIButton * blackButton;

@property (nonatomic, strong) UITextField * selectedTextField;
@property (nonatomic, strong) NSMutableArray * textFields;
@property (nonatomic, strong) NSArray * fieldOrder;

@property (nonatomic, strong) UITapGestureRecognizer * keyboardTapGestureRecognizer;

@property (nonatomic, strong) ExersiteHTTPClient * httpClient;

- (void)didTapMoreInformationLabel:(id)sender;
- (void)didTapPreviousNextFormElement:(id)sender;

- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;

- (void)didTapScrollView:(id)sender;

@end
