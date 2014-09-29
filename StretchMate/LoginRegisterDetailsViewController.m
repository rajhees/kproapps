//
//  LoginRegisterDetailsViewController.m
//  Exersite
//
//  Created by James Eunson on 4/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "LoginRegisterDetailsViewController.h"
#import "LoginButtonCell.h"
#import "ProgressHUDHelper.h"
#import "UIImageView+AFNetworking.h"
#import "LoginPractitionerCell.h"
#import "LoginSegmentedControlButton.h"
#import "ExersiteSessionAuthenticator.h"

#define kNameFieldTag 100
#define kEmailFieldTag 101
#define kPasswordFieldTag 102
#define kConfirmPasswordFieldTag 103

static NSString * kPractitionerCellIdentifier = @"practitionerCell";

static NSString * kNameCellIdentifier = @"nameCellIdentifier";
static NSString * kEmailCellIdentifier = @"emailCellIdentifier";
static NSString * kPasswordCellIdentifier = @"passwordCellIdentifier";
static NSString * kConfirmPasswordCellIdentifier = @"confirmPasswordCellIdentifier";

static NSString * kConfirmRegistrationCellIdentifier = @"confirmRegistrationCellIdentifier";

@interface LoginRegisterDetailsViewController ()

@property (nonatomic, strong) UITextField * nameField;
@property (nonatomic, strong) UITextField * emailField;
@property (nonatomic, strong) UITextField * passwordField;
@property (nonatomic, strong) UITextField * confirmPasswordField;

@property (nonatomic, strong) CALayer * nameBorderLayer;
@property (nonatomic, strong) CALayer * emailBorderLayer;
@property (nonatomic, strong) CALayer * passwordBorderLayer;

- (void)confirmRegistration;
- (void)resignKeyboard:(id)sender;

@end

@implementation LoginRegisterDetailsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.fieldOrder = @[ @(kNameFieldTag), @(kEmailFieldTag), @(kPasswordFieldTag), @(kConfirmPasswordFieldTag) ];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.tableView registerClass:[LoginPractitionerCell class] forCellReuseIdentifier:kPractitionerCellIdentifier];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kNameCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kEmailCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kPasswordCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kConfirmPasswordCellIdentifier];
    
    [self.tableView registerClass:[LoginButtonCell class] forCellReuseIdentifier:kConfirmRegistrationCellIdentifier];
    
    // Compensate for six button layout
//    [self updateLayoutWithNewTableViewHeight:416.0f];
    
    // Header
    self.headerView.headingLabel.text = @"Confirm Account";
    self.headerView.subHeadingLabel.text = @"Fill in the following information to proceed. You will receive an email once your account is created.";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Confirm Account";
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 620.0f);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
//    _tableViewDividerBorderLayer.frame = CGRectMake(0, 43.0f, self.view.frame.size.width, 1.0f);
    
    self.tableViewBackgroundView.frame = CGRectMake(0, self.headerView.frame.origin.y + self.headerView.frame.size.height, self.view.frame.size.width, 432.0f);
    self.tableView.frame = CGRectMake(0, self.headerView.frame.origin.y + self.headerView.frame.size.height, self.view.frame.size.width, 432.0f);
    
    CGSize sizeForInvitationNoticeLabel = [self.invitationNoticeLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 20.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.invitationNoticeLabel.frame = CGRectMake(10, self.headerView.frame.origin.y + self.headerView.frame.size.height + self.tableView.frame.size.height + 10.0f, self.view.frame.size.width - 20.0f, sizeForInvitationNoticeLabel.height);
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) {
        return 1;
    } else if(section == 1) {
        return 4;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        
        LoginPractitionerCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPractitionerCellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(_serverResponseDict && [[_serverResponseDict allKeys] count] > 0) {
            if([[_serverResponseDict allKeys] containsObject:@"practitioner"]) {
                cell.textLabel.text = _serverResponseDict[@"practitioner"];
            }
            if([[_serverResponseDict allKeys] containsObject:@"practice"]) {
                
                NSDictionary * practice = _serverResponseDict[@"practice"];
                if(practice && [[practice allKeys] containsObject:@"image"]) {
                    
                    NSURL * practiceImageURL = [NSURL URLWithString:practice[@"image"]];
                    NSURLRequest * request = [NSURLRequest requestWithURL:practiceImageURL];
                    
                    __block UITableViewCell * blockCell = cell;
                    [cell.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                        
                        blockCell.imageView.image = image;
                        [blockCell setNeedsLayout];
                        
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                        NSLog(@"Unable to retrieve practice image at url: %@", practiceImageURL);
                    }];
                }
                if(practice && [[practice allKeys] containsObject:@"name"]) {
                    cell.detailTextLabel.text = practice[@"name"];
                }
                
                if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                }
            }
        }
        
        return cell;
        
    } else if(indexPath.section == 1) {

        
        if(indexPath.row == 0) {
            
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kNameCellIdentifier forIndexPath:indexPath];
            
            _nameField = [[UITextField alloc] initWithFrame:CGRectMake(8, 10, self.tableView.frame.size.width-40, textFieldHeight)];
            _nameField.tag = kNameFieldTag;
            [self.textFields addObject:_nameField];
            [cell.contentView addSubview:_nameField];
            
            _nameField.placeholder = @"Your Name";            
            _nameField.inputAccessoryView = self.fieldToolbar;
            _nameField.autocorrectionType = UITextAutocorrectionTypeNo;                        
            _nameField.delegate = self;
            _nameField.returnKeyType = UIReturnKeyNext;
            _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;              
            
            // Populate field with name value if available, and the user hasn't already entered something here
            if([_nameField.text length] == 0 && _serverResponseDict &&
               [[_serverResponseDict allKeys] containsObject:@"name"] && [_serverResponseDict[@"name"] length] != 0) {
                
                _nameField.text = _serverResponseDict[@"name"];
            }
            
            _nameBorderLayer = [CALayer layer];
            _nameBorderLayer.backgroundColor = [RGBCOLOR(204, 204, 204) CGColor];
            _nameBorderLayer.frame = CGRectMake(0, 43.0f, self.view.frame.size.width, 1.0f);
            [cell.layer insertSublayer:_nameBorderLayer atIndex:100];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        } else if(indexPath.row == 1) {
            
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
            
            _emailBorderLayer = [CALayer layer];
            _emailBorderLayer.backgroundColor = [RGBCOLOR(204, 204, 204) CGColor];
            _emailBorderLayer.frame = CGRectMake(0, 43.0f, self.view.frame.size.width, 1.0f);
            [cell.layer insertSublayer:_emailBorderLayer atIndex:100];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        } else if(indexPath.row == 2) {
            
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPasswordCellIdentifier forIndexPath:indexPath];
            
            _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(8, 10, self.tableView.frame.size.width-40, textFieldHeight)];
            _passwordField.tag = kPasswordFieldTag;
            [self.textFields addObject:_passwordField];               
            [cell.contentView addSubview:_passwordField];
            
            _passwordField.placeholder = @"Your Password";
            _passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            _passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
            _passwordField.returnKeyType = UIReturnKeyNext;
            _passwordField.secureTextEntry = YES;
            _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
            
            _passwordField.inputAccessoryView = self.fieldToolbar;
            _passwordField.delegate = self;
            
            _passwordBorderLayer = [CALayer layer];
            _passwordBorderLayer.backgroundColor = [RGBCOLOR(204, 204, 204) CGColor];
            _passwordBorderLayer.frame = CGRectMake(0, 43.0f, self.view.frame.size.width, 1.0f);
            [cell.layer insertSublayer:_passwordBorderLayer atIndex:100];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        } else if(indexPath.row == 3) {
            
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kConfirmPasswordCellIdentifier forIndexPath:indexPath];
            
            _confirmPasswordField = [[UITextField alloc] initWithFrame:CGRectMake(8, 10, self.tableView.frame.size.width-40, textFieldHeight)];
            _confirmPasswordField.tag = kConfirmPasswordFieldTag;
            [self.textFields addObject:_confirmPasswordField];                           
            [cell.contentView addSubview:_confirmPasswordField];
            
            _confirmPasswordField.placeholder = @"Re-enter your password";
            _confirmPasswordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            _confirmPasswordField.autocorrectionType = UITextAutocorrectionTypeNo;
            _confirmPasswordField.returnKeyType = UIReturnKeyNext;
            _confirmPasswordField.secureTextEntry = YES;
            _confirmPasswordField.clearButtonMode = UITextFieldViewModeWhileEditing;            
            
            _confirmPasswordField.inputAccessoryView = self.fieldToolbar;
            _confirmPasswordField.delegate = self;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
    } else {
        
        LoginButtonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kConfirmRegistrationCellIdentifier forIndexPath:indexPath];
        cell.type = LoginButtonCellTypeConfirmRegistration;
        cell.textLabel.text = @"Confirm Registration";
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 2) {
        [self confirmRegistration];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        return 66.0f;
        
    } else {
        return 44.0f;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Your Practitioner";
    } else if(section == 1) {
        return @"Your Account";
    }
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, 38.0f)];
    customView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGSize theSize = [[self tableView:self.tableView titleForHeaderInSection:section] sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 20, CGFLOAT_MAX)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, theSize.width, (theSize.height + 11.0f))];
    label.text = [[self tableView].dataSource tableView:[self tableView] titleForHeaderInSection:section];
    label.textColor = RGBCOLOR(41, 41, 41);
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [customView addSubview:label];
    
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if(section == 0 || section == 1) {
        return 38.0f;
    }
    return 0;
}

#pragma mark - Property Override Methods
- (void)setServerResponseDict:(NSDictionary *)serverResponseDict {
    _serverResponseDict = serverResponseDict;
    
    [self.tableView reloadData];
}

#pragma mark - Private Methods
- (void)confirmRegistration {
    
    // Local field presence validation
    if([self.nameField.text length] == 0 || [self.emailField.text length] == 0 || [self.passwordField.text length] == 0 || [self.confirmPasswordField.text length] == 0) {
        
        NSString * fieldName = nil;
        if([self.nameField.text length] == 0) {
            fieldName = self.nameField.placeholder;
        } else if([self.emailField.text length] == 0) {
            fieldName = self.emailField.placeholder;
        } else if([self.passwordField.text length] == 0) {
            fieldName = self.passwordField.placeholder;
        } else if([self.confirmPasswordField.text length] == 0) {
            fieldName = self.confirmPasswordField.placeholder;     
        }
        
        if(fieldName) {
            NSString * message = [NSString stringWithFormat:@"You have not entered anything in the '%@' field. Please check this field and try again.", fieldName];
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }
    
    if(![self.passwordField.text isEqualToString:self.confirmPasswordField.text]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You have not entered the same password in the 'Your Password' and 'Re-enter your password' fields. Please clear these and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:@"Registering Account" withDetailsLabelText:nil];
    [loadingView show:YES];
    
//    NSDictionary * parameters = @{@"code": self.practitionerCodeField.text, @"dob": [@([self.selectedDateOfBirth timeIntervalSince1970]) stringValue]};
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc] init];
    [parameters addEntriesFromDictionary:self.invitationDetailsDict];
    parameters[@"user"] = @{ @"name": self.nameField.text, @"email": self.emailField.text, @"password": self.passwordField.text, @"password_confirmation": self.confirmPasswordField.text };
    
    [self.httpClient confirmRegistrationWithParameters:parameters completion:^(NSDictionary *result) {
        
        [loadingView hide:YES];
        
        if([result[@"success"] boolValue]) {
            
            // Perform user login
            NSString * email = _emailField.text.length > 0 ? _emailField.text : @"";
            NSString * password = _passwordField.text.length > 0 ? _passwordField.text : @"";
            
            NSDictionary * userDetails = @{ @"email" : email, @"password": password };
            
            [ExersiteSessionAuthenticator authenticateWithUserDetails:userDetails completion:^(BOOL success) {}];
            
            [self performSegueWithIdentifier:@"LoginRegisterCompleteSegue" sender:nil];
            
        } else {
            
            NSString * errorMessage = nil;
            if([[result allKeys] containsObject:@"errors"]) {
                
                NSDictionary * errors = result[@"errors"];
                NSString * firstKey = [[errors allKeys] firstObject];
                NSArray * errorsForKey = errors[firstKey];
                
                NSString * ucfirstFirstKey = [firstKey stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[firstKey substringToIndex:1] uppercaseString]];
                errorMessage = [NSString stringWithFormat:@"%@ %@. Please check the '%@' field and try again.", ucfirstFirstKey, [errorsForKey firstObject], ucfirstFirstKey];
                
            } else {
                errorMessage = @"An error occurred while attempting to confirm account registration. Please try again later.";
            }
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

- (void)resignKeyboard:(id)sender {
    
    [_nameField resignFirstResponder];
    [_emailField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_confirmPasswordField resignFirstResponder];
}

@end
