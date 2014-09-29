//
//  LoginRegisterViewController.m
//  Exersite
//
//  Created by James Eunson on 3/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "LoginRegisterViewController.h"
#import "LoginButtonCell.h"
#import "LoginRegisterBlackButtonCell.h"
#import "NSDate+TKCategory.h"
#import "ProgressHUDHelper.h"
#import "LoginRegisterDetailsViewController.h"
#import "LoginSegmentedControlButton.h"
#import "LoginMoreInformationViewController.h"

#define kPractitionerCodeFieldTag 100
#define kDateOfBirthFieldTag 101

static NSString * kPractitionerCodeCellIdentifier = @"practitionerCodeCell";
static NSString * kDateOfBirthCellIdentifier = @"dateOfBirthCell";
static NSString * kRegisterButtonCellIdentifier = @"registerButtonCell";
static NSString * kBlackButtonCellIdentifier = @"blackButtonCellIdentifier";

@interface LoginRegisterViewController ()

@property (nonatomic, strong) UITextField * practitionerCodeField;
@property (nonatomic, strong) UITextField * dateOfBirthField;

@property (nonatomic, strong) UIDatePicker * datePicker;

@property (nonatomic, strong) NSDate * selectedDateOfBirth;

@property (nonatomic, strong) NSString * stringForSelectedDateOfBirth;
@property (nonatomic, strong) NSDateFormatter * dateFormatter;

@property (nonatomic, strong) UIButton * practitionerButton;
@property (nonatomic, strong) UIButton * noCodeButton;

@property (nonatomic, strong) CALayer * tableViewDividerBorderLayer;

@property (nonatomic, strong) ExersiteHTTPClient * httpClient;

- (void)resignKeyboard:(id)sender;
- (void)didChangeDateForDatePicker:(id)sender;

- (void)didTapPractitionerButton:(id)sender;
- (void)didTapNoCodeButton:(id)sender;

- (void)startRegistration;

@end

@implementation LoginRegisterViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        // Requirement for inherited controller of LoginBaseViewController
        self.fieldOrder = @[ @(kPractitionerCodeFieldTag), @(kDateOfBirthFieldTag) ];
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"dd MMMM, yyyy"];
        
        NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [_dateFormatter setLocale:locale];
        
        self.stringForSelectedDateOfBirth = [_dateFormatter stringFromDate:[NSDate date]];
        
//        self.selectedDateOfBirth = [NSDate dateWithDay:10 andMonth:5 andYear:1987];
//        self.stringForSelectedDateOfBirth = [_dateFormatter stringFromDate:_selectedDateOfBirth];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kPractitionerCodeCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDateOfBirthCellIdentifier];
    [self.tableView registerClass:[LoginButtonCell class] forCellReuseIdentifier:kRegisterButtonCellIdentifier];
    [self.tableView registerClass:[LoginRegisterBlackButtonCell class] forCellReuseIdentifier:kBlackButtonCellIdentifier];
    
//    [self updateLayoutWithNewTableViewHeight:268.0f];
    
    // Header
    self.headerView.headingLabel.text = @"Register for Exersite";
    self.headerView.subHeadingLabel.text = @"Enter the practitioner code you have received via SMS below, as well as your date of birth for security verification.";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Register";
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 420.0f);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.tableViewBackgroundView.frame = CGRectMake(0, self.headerView.frame.origin.y + self.headerView.frame.size.height, self.view.frame.size.width, 265.0f);
    self.tableView.frame = CGRectMake(0, self.headerView.frame.origin.y + self.headerView.frame.size.height, self.view.frame.size.width, 265.0f);
    self.tableViewDividerBorderLayer.frame = CGRectMake(0, 43.0f, self.view.frame.size.width, 1.0f);
    
    CGSize sizeForInvitationNoticeLabel = [self.invitationNoticeLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 20.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.invitationNoticeLabel.frame = CGRectMake(10, self.headerView.frame.origin.y + self.headerView.frame.size.height + self.tableView.frame.size.height + 10.0f, self.view.frame.size.width - 20.0f, sizeForInvitationNoticeLabel.height);
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) {
        return 2;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    if(indexPath.section == 0) {
        
        if(indexPath.row == 0) {

            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPractitionerCodeCellIdentifier forIndexPath:indexPath];
            
            _practitionerCodeField = [[UITextField alloc] initWithFrame:CGRectMake(8, 0, self.tableView.frame.size.width-16, 44.0f)];
            _practitionerCodeField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:_practitionerCodeField];
            
            _practitionerCodeField.tag = kPractitionerCodeFieldTag;
            [self.textFields addObject:_practitionerCodeField];
            
            _practitionerCodeField.placeholder = @"Practitioner Code";
            _practitionerCodeField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            _practitionerCodeField.inputAccessoryView = self.fieldToolbar;
            _practitionerCodeField.delegate = self;
            
            _tableViewDividerBorderLayer = [CALayer layer];
            _tableViewDividerBorderLayer.backgroundColor = [RGBCOLOR(204, 204, 204) CGColor];
            _tableViewDividerBorderLayer.frame = CGRectMake(0, 43.0f, self.view.frame.size.width, 1.0f);
            [cell.layer insertSublayer:_tableViewDividerBorderLayer atIndex:100];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;            
            return cell;
            
        } else if(indexPath.row == 1) {
            
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDateOfBirthCellIdentifier forIndexPath:indexPath];
            
            _dateOfBirthField = [[UITextField alloc] initWithFrame:CGRectMake(8, 0, self.tableView.frame.size.width-16, 44.0f)];
            _dateOfBirthField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:_dateOfBirthField];
            
            _dateOfBirthField.tag = kDateOfBirthFieldTag;
            [self.textFields addObject:_dateOfBirthField];
            
            _dateOfBirthField.placeholder = @"Date of Birth";
            _dateOfBirthField.inputAccessoryView = self.fieldToolbar;
            
            _datePicker = [[UIDatePicker alloc] init];
            _datePicker.datePickerMode = UIDatePickerModeDate;
            _datePicker.maximumDate = [[NSDate date] dateByAddingMonths:(-(10 * 12))];
            _dateOfBirthField.inputView = _datePicker;
            
            [_datePicker addTarget:self action:@selector(didChangeDateForDatePicker:) forControlEvents:UIControlEventValueChanged];
            
            _dateOfBirthField.delegate = self;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
    } else {
        
        if(indexPath.row == 0) {
            
            LoginButtonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kRegisterButtonCellIdentifier forIndexPath:indexPath];
            cell.type = LoginButtonCellTypeRegister;
            cell.textLabel.text = @"Register";
            return cell;
            
        } else {
            
            LoginRegisterBlackButtonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kBlackButtonCellIdentifier forIndexPath:indexPath];
            
            if(indexPath.row == 1) {
                cell.textLabel.text = @"I'm a patient with no practitioner code.";
            } else if(indexPath.row == 2) {
                cell.textLabel.text = @"I'm a practitioner";
            }
            return cell;
        }
    }
    
    return [[UITableViewCell alloc] init];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 1) {
        if(indexPath.row == 0) {
            [self startRegistration];
        } else if(indexPath.row == 1) {
            [self performSegueWithIdentifier:@"LoginMoreInformationSegue" sender:@{ @"anchor": @"patient-without-code"}];
        } else if(indexPath.row == 2) {
            [self performSegueWithIdentifier:@"LoginMoreInformationSegue" sender:@{ @"anchor": @"practitioner" }];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0)) {
        return 44.0f;
    } else {
        return 40.0f;
    }
}

#pragma mark - Private Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"LoginRegisterDetailsSegue"]) {
        
        NSDictionary * serverResponseDict = (NSDictionary*)sender;
        
        LoginRegisterDetailsViewController * detailsViewController = (LoginRegisterDetailsViewController*)segue.destinationViewController;
        detailsViewController.serverResponseDict = serverResponseDict;
        
        NSDictionary * invitationDetailsDict = @{@"code": self.practitionerCodeField.text, @"dob": [@([self.selectedDateOfBirth timeIntervalSince1970]) stringValue]};
        detailsViewController.invitationDetailsDict = invitationDetailsDict;
        
    } else if([[segue identifier] isEqualToString:@"LoginMoreInformationSegue"]) {
        
        NSDictionary * anchorDict = (NSDictionary*)sender;
        LoginMoreInformationViewController * detailsViewController = (LoginMoreInformationViewController*)segue.destinationViewController;
        
        detailsViewController.initialAnchor = anchorDict[@"anchor"];
    }
}

- (void)startRegistration {
    
    // Validate
    if([self.dateOfBirthField.text length] == 0 || [self.practitionerCodeField.text length] != 6) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select your date of birth and enter a valid practitioner code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:@"Checking Invitation" withDetailsLabelText:nil];
    [loadingView show:YES];
    
    NSDictionary * parameters = @{@"code": self.practitionerCodeField.text, @"dob": [@([self.selectedDateOfBirth timeIntervalSince1970]) stringValue]};
    
    [self.httpClient attemptRegistrationWithParameters:parameters completion:^(NSDictionary *result) {
        
        [loadingView hide:YES];
        
        if([result[@"success"] boolValue]) {
            
            [self performSegueWithIdentifier:@"LoginRegisterDetailsSegue" sender:result];
            
        } else {

            NSString * errorMessage = nil;
            if([[result allKeys] containsObject:@"error"]) {
                errorMessage = result[@"error"];
            } else {
                errorMessage = @"An error occurred while attempting to register. Please try again later.";
            }
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

- (void)resignKeyboard:(id)sender {
    [_practitionerCodeField resignFirstResponder];
    [_dateOfBirthField resignFirstResponder];
}

//- (void)didTapPreviousNextFormElement:(id)sender {
//    NSLog(@"didTapPreviousNextFormElement");
//    
//    LoginSegmentedControlButton * segmentedControl = (LoginSegmentedControlButton*)sender;
//    LoginSegmentedControlButtonLastTouch lastTouch = segmentedControl.lastTouch;
//    
//    [self.textFields sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return [@(((UITextField*)obj1).tag) compare:@(((UITextField*)obj2).tag)];
//    }];
//    NSInteger indexOfField = [self.fieldOrder indexOfObject:@(self.selectedTextField.tag)];
//    
//    if(lastTouch == LoginSegmentedControlButtonLastTouchPrevious) {
//        if(indexOfField == 0) { // First
//            return;
//        }
//        [self.textFields[(indexOfField - 1)] becomeFirstResponder];
//        
//    } else if(lastTouch == LoginSegmentedControlButtonLastTouchNext) {
//        if(indexOfField == ([self.textFields count] - 1)) { // Last
//            return;
//        }
//        [self.textFields[(indexOfField + 1)] becomeFirstResponder];
//    }
//}

- (void)didChangeDateForDatePicker:(id)sender {
    
    UIDatePicker * datePicker = (UIDatePicker*)sender;
    
    self.selectedDateOfBirth = datePicker.date;
    self.stringForSelectedDateOfBirth = [_dateFormatter stringFromDate:_selectedDateOfBirth];
    
    _dateOfBirthField.text = _stringForSelectedDateOfBirth;
}

- (void)didTapPractitionerButton:(id)sender {
    [self performSegueWithIdentifier:@"LoginMoreInformationSegue" sender:nil];
}
- (void)didTapNoCodeButton:(id)sender {
    [self performSegueWithIdentifier:@"LoginMoreInformationSegue" sender:nil];
}

#pragma mark - Property Override Methods
- (UIButton*)practitionerButton {
    
    if(_practitionerButton) {
        return _practitionerButton;
    }
    
    UIButton * practitionerButton = [self blackButton];
    practitionerButton.frame = CGRectMake(10, 8, ((self.view.frame.size.width - 30) / 2), 33.0f);
    [practitionerButton setTitle:@"I'm a practitioner" forState:UIControlStateNormal];
    
    [practitionerButton addTarget:self action:@selector(didTapPractitionerButton:) forControlEvents:UIControlEventTouchUpInside];
    
    _practitionerButton = practitionerButton;
    
    return _practitionerButton;
}

- (UIButton*)noCodeButton {
    
    if(_noCodeButton) {
        return _noCodeButton;
    }
    
    UIButton * noCodeButton = [self blackButton];
    noCodeButton.frame = CGRectMake(((self.view.frame.size.width - 30) / 2) + 20.0f, 8, ((self.view.frame.size.width - 30) / 2), 33.0f);
    [noCodeButton setTitle:@"I don't have a code" forState:UIControlStateNormal];
    
    [noCodeButton addTarget:self action:@selector(didTapNoCodeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    _noCodeButton = noCodeButton;
    
    return _noCodeButton;
}

@end
