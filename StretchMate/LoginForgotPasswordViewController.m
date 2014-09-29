//
//  LoginForgotPasswordViewController.m
//  Exersite
//
//  Created by James Eunson on 3/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "LoginForgotPasswordViewController.h"
#import "LoginButtonCell.h"
#import "ProgressHUDHelper.h"

#define kEmailFieldTag 100

static NSString * kEmailCellIdentifier = @"emailCell";
static NSString * kResetPasswordCellIdentifier = @"resetPasswordCell";

@interface LoginForgotPasswordViewController ()

@property (nonatomic, strong) UITextField * emailField;

- (void)resetPassword;
- (void)resignKeyboard:(id)sender;

@end

@implementation LoginForgotPasswordViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.fieldOrder = @[ @(kEmailFieldTag) ];        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kEmailCellIdentifier];
    [self.tableView registerClass:[LoginButtonCell class] forCellReuseIdentifier:kResetPasswordCellIdentifier];
    
    self.headerView.headingLabel.text = @"Forgotten Password";
    self.headerView.subHeadingLabel.text = @"Enter your email below and hit the Reset Password button to send a reset email to your registered email address.";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Reset Password";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.tableViewBackgroundView.frame = CGRectMake(0, self.headerView.frame.origin.y + self.headerView.frame.size.height, self.view.frame.size.width, 178.0f);
    self.tableView.frame = CGRectMake(0, self.headerView.frame.origin.y + self.headerView.frame.size.height, self.view.frame.size.width, 178.0f);
    
    CGSize sizeForInvitationNoticeLabel = [self.invitationNoticeLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 20.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.invitationNoticeLabel.frame = CGRectMake(10, self.headerView.frame.origin.y + self.headerView.frame.size.height + self.tableView.frame.size.height + 10.0f, self.view.frame.size.width - 20.0f, sizeForInvitationNoticeLabel.height);
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) {
        return 1;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kEmailCellIdentifier forIndexPath:indexPath];
        
        _emailField = [[UITextField alloc] initWithFrame:CGRectMake(8, 10, self.tableView.frame.size.width-40, textFieldHeight)];
        _emailField.tag = kEmailFieldTag;
        [self.textFields addObject:_emailField];
        [cell.contentView addSubview:_emailField];
        
        _emailField.placeholder = @"Your Email Address";
        _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        _emailField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailField.returnKeyType = UIReturnKeyNext;
        _emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        _emailField.inputAccessoryView = self.fieldToolbar;
        _emailField.delegate = self;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else { // section == 1
        
        LoginButtonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kResetPasswordCellIdentifier forIndexPath:indexPath];
        cell.type = LoginButtonCellTypeResetPassword;
        cell.textLabel.text = @"Reset Password";
        return cell;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        [self resetPassword];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if(section == 1) {
        return @"Please enter the email address you used to sign up to Exersite.";
    }
    
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if(section == 0) return nil;
    
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 60, 44.0)];
    customView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGSize theSize = [[self tableView:self.tableView titleForFooterInSection:section] sizeWithFont:[UIFont boldSystemFontOfSize:13.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 60, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, theSize.width, (theSize.height + 11.0f))];
    label.text = [[self tableView].dataSource tableView:[self tableView] titleForFooterInSection:section];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:13.0f];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    if ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        label.shadowColor = [UIColor blackColor];
        label.textColor = RGBCOLOR(153, 153, 153);
    } else {
        label.textColor = RGBCOLOR(116, 116, 116);
    }
    
    [customView addSubview:label];
    
    return customView;
}

#pragma mark - Private Methods
- (void)resetPassword {
    
    if([self.emailField.text length] == 0) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must enter your email address to perform a password reset." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:@"Resetting Password" withDetailsLabelText:nil];
    [loadingView show:YES];
    
    NSDictionary * parameters = @{ @"email" : self.emailField.text };
    [self.httpClient resetPasswordWithParameters:parameters completion:^(NSDictionary *result) {
        
        [loadingView hide:YES];
        
        if([result[@"success"] boolValue]) {
            
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your account password has been reset. Please check your registered email address for further instructions." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            
        } else {
            
            NSString * message = nil;
            if([[result allKeys] containsObject:@"message"]) {
                message = result[@"message"];
            } else {
                message = @"Unable to reset your account password. Please ensure you have entered your email address correctly and try again.";
            }
            
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

- (void)resignKeyboard:(id)sender {
    
    [_emailField resignFirstResponder];
}

@end
