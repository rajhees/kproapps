//
//  LoginViewController.m
//  StretchMate
//
//  Created by James Eunson on 27/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginButtonCell.h"
#import "ProgressHUDHelper.h"
#import "LoginRegisterHeaderView.h"
#import "ExersiteSessionAuthenticator.h"
#import "KeychainItemWrapper.h"
#import "ExersiteSession.h"

#define kEmailFieldTag 100
#define kPasswordFieldTag 101

static NSString * kLoginCellIdentifier = @"loginCell";

#define kTitleString @"Login to Exersite"
#define kSubtitleString @"Enter your Exersite account information below or register using your invitation from your practitioner (SMS code)."

@interface LoginViewController ()
- (void)didTapLoginButton:(id)sender;
- (void)didTapRegisterButton:(id)sender;
- (void)didTapForgotPasswordButton:(id)sender;

- (void)resignKeyboard:(id)sender;

- (void)startAuthenticationWithSavedCredentials;

@property (nonatomic, strong) UITextField * emailField;
@property (nonatomic, strong) UITextField * passwordField;

@property (nonatomic, strong, readonly) UIButton * registerButton;
@property (nonatomic, strong, readonly) UIButton * forgotPasswordButton;

@property (nonatomic, strong) CALayer * tableViewDividerBorderLayer;

@end

@implementation LoginViewController

@synthesize registerButton = _registerButton;
@synthesize forgotPasswordButton = _forgotPasswordButton;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.shouldAuthenticateUsingSavedCredentials = NO;
        self.fieldOrder = @[ @(kEmailFieldTag), @(kPasswordFieldTag) ];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kLoginCellIdentifier];
    [self.tableView registerClass:[LoginButtonCell class] forCellReuseIdentifier:kLoginButtonCellIdentifier];
    
    // Header
    self.headerView.headingLabel.text = kTitleString;
    self.headerView.subHeadingLabel.text = kSubtitleString;
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.doneItem.target = self.cancelItem.target = self;
    self.doneItem.action = @selector(didTapLoginButton:);
    self.cancelItem.action = @selector(dismissModalViewControllerAnimated:);
    
    self.title = @"Login";
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 400.0f);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.shouldAuthenticateUsingSavedCredentials) {
        [self startAuthenticationWithSavedCredentials];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _tableViewDividerBorderLayer.frame = CGRectMake(0, 43.0f, self.view.frame.size.width, 1.0f);
    
    self.tableViewBackgroundView.frame = CGRectMake(0, self.headerView.frame.origin.y + self.headerView.frame.size.height, self.view.frame.size.width, 225.0f);
    self.tableView.frame = CGRectMake(0, self.headerView.frame.origin.y + self.headerView.frame.size.height, self.view.frame.size.width, 225);
    
    self.forgotPasswordButton.frame = CGRectMake(8.0f, 8, ((self.view.frame.size.width - 24) / 2), 33.0f);
    self.registerButton.frame = CGRectMake(((self.view.frame.size.width - 30) / 2) + 20.0f, 8, ((self.view.frame.size.width - 30) / 2), 33.0f);
    
    CGSize sizeForInvitationNoticeLabel = [self.invitationNoticeLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 20.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.invitationNoticeLabel.frame = CGRectMake(10, self.headerView.frame.origin.y + self.headerView.frame.size.height + self.tableView.frame.size.height + 10.0f, self.view.frame.size.width - 20.0f, sizeForInvitationNoticeLabel.height);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kLoginCellIdentifier forIndexPath:indexPath];
        
        if(indexPath.row == 0 && !_emailField) {
            
            _emailField = [[UITextField alloc] initWithFrame:CGRectMake(8, 0, self.tableView.frame.size.width-16, 44.0f)];
            _emailField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:_emailField];
            
            _emailField.tag = kEmailFieldTag;
            [self.textFields addObject:_emailField];
            
            _emailField.placeholder = @"Email";
            _emailField.keyboardType = UIKeyboardTypeEmailAddress;
            _emailField.returnKeyType = UIReturnKeyNext;
            _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
            
            _emailField.inputAccessoryView = self.fieldToolbar;
            
            _emailField.delegate = self;
            
            _tableViewDividerBorderLayer = [CALayer layer];
            _tableViewDividerBorderLayer.backgroundColor = [RGBCOLOR(204, 204, 204) CGColor];
            _tableViewDividerBorderLayer.frame = CGRectMake(0, 43.0f, self.view.frame.size.width, 1.0f);
            [cell.layer insertSublayer:_tableViewDividerBorderLayer atIndex:100];
            
        } else if(indexPath.row == 1 && !_passwordField) {
            
            _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(8, 0, self.tableView.frame.size.width-16, 44.0f)];
            _passwordField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:_passwordField];
            
            _passwordField.tag = kPasswordFieldTag;
            [self.textFields addObject:_passwordField];
            
            _passwordField.placeholder = @"Password";
            _passwordField.secureTextEntry = YES;
            _passwordField.returnKeyType = UIReturnKeyDone;
            
            _passwordField.inputAccessoryView = self.fieldToolbar;            
            
            _passwordField.delegate = self;            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else {
        
        LoginButtonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kLoginButtonCellIdentifier forIndexPath:indexPath];
        cell.type = LoginButtonCellTypeLogin;
        
        cell.textLabel.text = @"Login";
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 1) {
        [self didTapLoginButton:nil];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if(section == 0) return nil;
    
    self.footerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _footerContainerView.userInteractionEnabled = YES;
    _footerContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [_footerContainerView addSubview:self.forgotPasswordButton];
    [_footerContainerView addSubview:self.registerButton];
    
    return _footerContainerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if(section == 0) return 0;
    
    return 44.0f;
}

#pragma mark - Private Methods
- (void)didTapLoginButton:(id)sender {
    [self startAuthentication];
}

- (void)didTapRegisterButton:(id)sender {
    [self performSegueWithIdentifier:@"LoginRegisterSegue" sender:nil];
}

- (void)didTapForgotPasswordButton:(id)sender {
    [self performSegueWithIdentifier:@"LoginForgotPasswordSegue" sender:nil];    
}

- (void)startAuthentication {
    
    NSString * email = _emailField.text.length > 0 ? _emailField.text : @"";
    NSString * password = _passwordField.text.length > 0 ? _passwordField.text : @"";
    
    NSDictionary * userDetails = @{ @"email" : email, @"password": password };
    
    [ExersiteSessionAuthenticator authenticateWithUserDetails:userDetails completion:^(BOOL success) {
        if(success) {
            if([self.delegate respondsToSelector:@selector(loginViewControllerDidLogin:)]) {
                [self.delegate performSelector:@selector(loginViewControllerDidLogin:) withObject:self];
            }
        }
    }];
}

- (void)startAuthenticationWithSavedCredentials {
    
    KeychainItemWrapper * userCredentials = [[ExersiteSession currentSession] userCredentials];
    NSString * email = [userCredentials objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [userCredentials objectForKey:(__bridge id)kSecValueData];
    
    self.emailField.text = email;
    self.passwordField.text = password;
    
    NSDictionary * userDetails = @{ @"email" : email, @"password": password };
    
    [ExersiteSessionAuthenticator authenticateWithUserDetails:userDetails completion:^(BOOL success) {
        if(success) {
            if([self.delegate respondsToSelector:@selector(loginViewControllerDidLogin:)]) {
                [self.delegate performSelector:@selector(loginViewControllerDidLogin:) withObject:self];
            }
        } else {
            if([self.delegate respondsToSelector:@selector(loginViewControllerLoginDidFail:)]) {
                [self.delegate performSelector:@selector(loginViewControllerLoginDidFail:) withObject:self];
            }
        }
    }];
}

- (void)resignKeyboard:(id)sender {
    
    [_emailField resignFirstResponder];
    [_passwordField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(textField == _emailField) {
        [_passwordField becomeFirstResponder];
    } else {
        [_passwordField resignFirstResponder];
        [self startAuthentication];
    }
    
    return YES;
}

#pragma mark - Property Override Methods
- (UIButton*)forgotPasswordButton {
    
    if(_forgotPasswordButton) {
        return _forgotPasswordButton;
    }
    
    UIButton * forgottenPasswordButton = [self blackButton];
    _forgotPasswordButton = forgottenPasswordButton;
    [_forgotPasswordButton setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [_forgotPasswordButton addTarget:self action:@selector(didTapForgotPasswordButton:) forControlEvents:UIControlEventTouchUpInside];

    return _forgotPasswordButton;
}

- (UIButton*)registerButton {
    
    if(_registerButton) {
        return _registerButton;
    }
    
    // Frame indicates this "orange" button on right of black button
    UIButton * registerButton = [[UIButton alloc] init];
    [registerButton setTitle:@"Register" forState:UIControlStateNormal];
    registerButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [registerButton setTitleShadowColor:RGBCOLOR(183, 87, 30) forState:UIControlStateNormal];
        registerButton.titleLabel.shadowOffset = CGSizeMake(0, -1.0f);
        
        UIImage * backgroundImageForOrangeButton = [[UIImage imageNamed:@"login-register-orange-button"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 11, 9, 9)];
        [registerButton setBackgroundImage:backgroundImageForOrangeButton forState:UIControlStateNormal];
        
    } else {
        
        registerButton.backgroundColor = kTintColour;
        registerButton.layer.cornerRadius = 4.0f;
    }
    
    [registerButton addTarget:self action:@selector(didTapRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
    
    _registerButton = registerButton;
    return _registerButton;
}

@end
