//
//  LoginBaseViewController.m
//  Exersite
//
//  Created by James Eunson on 3/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "LoginBaseViewController.h"
#import "LoginSegmentedControlButton.h"
#import "LoginRegisterDetailsViewController.h"

#define kLoginBackgroundWidth 804.0f

@interface LoginBaseViewController ()

@property (nonatomic, strong) UIView * backgroundImageView;
@property (nonatomic, strong) CALayer * toolbarBottomBorder;

@property (nonatomic, strong) UIImageView * tableTopDarkenOverlay;

@end

@implementation LoginBaseViewController
@synthesize invitationNoticeLabel = _invitationNoticeLabel;
@synthesize fieldToolbar = _fieldToolbar;
@synthesize blackButton = _blackButton;

- (void)dealloc {
    [self unregisterKeyboardNotifications];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.textFields = [[NSMutableArray alloc] init];
        self.httpClient = [[ExersiteHTTPClient alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.scrollView = [[UIScrollView alloc] init]; // WithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
//    [self.scrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    
    self.headerView = [[LoginRegisterHeaderView alloc] initWithFrame:CGRectZero];
    [self.scrollView addSubview:_headerView];
    
    self.tableViewBackgroundView = [[UIView alloc] init];
    _tableViewBackgroundView.backgroundColor = RGBCOLOR(189, 189, 189);
    [self.scrollView addSubview:_tableViewBackgroundView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    
    if ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        self.backgroundImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLoginBackgroundWidth * 3, self.view.frame.size.height)];
        _backgroundImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login-bg"]];
        [self.view addSubview:_backgroundImageView];
        [self.view sendSubviewToBack:_backgroundImageView];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    }
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // Add padding view to table
    UIView * headerPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 7)];
    headerPaddingView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerPaddingView;
    
    [self.scrollView addSubview:self.tableView];

    if ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        
        self.tableTopDarkenOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-register-top-overlay"]];
        _tableTopDarkenOverlay.alpha = 0.2f;
        _tableTopDarkenOverlay.userInteractionEnabled = NO;
        [self.scrollView addSubview:_tableTopDarkenOverlay];
        
        self.tableBottomDarkenOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-register-bottom-overlay"]];
        _tableBottomDarkenOverlay.alpha = 0.2f;
        _tableBottomDarkenOverlay.userInteractionEnabled = NO;
        [self.scrollView addSubview:_tableBottomDarkenOverlay];
    }
    
    // Notice indication prospective patient must have invitation before registering
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.invitationNoticeBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-register-highlight-bottom-background"]];
        [self.scrollView addSubview:_invitationNoticeBackgroundImageView];
        [self.scrollView bringSubviewToFront:self.tableView];
        
    } else {
        self.navigationController.navigationBar.translucent = NO;
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    [self.scrollView addSubview:self.invitationNoticeLabel];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_scrollView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:Nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:Nil views:bindings]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat heightForHeaderView = [LoginRegisterHeaderView heightForHeaderViewWithTitle:self.headerView.headingLabel.text andSubtitle:self.headerView.subHeadingLabel.text];
    _headerView.frame = CGRectMake(0, 20.0f, self.view.frame.size.width, heightForHeaderView);

//    _tableView.frame = CGRectMake(0, _headerView.frame.origin.y + _headerView.frame.size.height, self.view.frame.size.width, 225);
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        _tableBottomDarkenOverlay.frame = CGRectMake(0, _headerView.frame.origin.y + _headerView.frame.size.height + _tableView.frame.size.height - _tableBottomDarkenOverlay.frame.size.height, _tableBottomDarkenOverlay.frame.size.width, _tableBottomDarkenOverlay.frame.size.height);
        
        _tableTopDarkenOverlay.frame = CGRectMake(0, _headerView.frame.origin.y + _headerView.frame.size.height, _tableTopDarkenOverlay.frame.size.width, _tableTopDarkenOverlay.frame.size.height);
        _invitationNoticeBackgroundImageView.frame = CGRectMake(0, _headerView.frame.origin.y + _headerView.frame.size.height + _tableView.frame.size.height, _invitationNoticeBackgroundImageView.frame.size.width, _invitationNoticeBackgroundImageView.frame.size.height);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
//    [UIView animateWithDuration:25.0 delay:0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear) animations:^{
//        _backgroundImageView.frame = CGRectMake(-(self.view.frame.size.width * 2), 0, self.view.frame.size.width * 3, self.view.frame.size.height);
//    } completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self unregisterKeyboardNotifications];
}

- (void)didTapMoreInformationLabel:(id)sender {
    [self performSegueWithIdentifier:@"LoginMoreInformationSegue" sender:nil];
}

- (UILabel*)invitationNoticeLabel {
    
    if(_invitationNoticeLabel) {
        return _invitationNoticeLabel;
    }
    
    UILabel * invitationNoticeLabel = [[UILabel alloc] init];
    
    invitationNoticeLabel.backgroundColor = [UIColor clearColor];
    invitationNoticeLabel.font = [UIFont systemFontOfSize:12.0f];
    invitationNoticeLabel.textColor = RGBCOLOR(105, 105, 105);
    invitationNoticeLabel.numberOfLines = 0;
    invitationNoticeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    invitationNoticeLabel.textAlignment = NSTextAlignmentCenter;
    invitationNoticeLabel.text = @"Practitioners should register via the Exersite website.\nPatients must be invited by practitioner via SMS.\nTap here for more information";
    
    UITapGestureRecognizer * tapGestureRecognizerForLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMoreInformationLabel:)];
    [invitationNoticeLabel addGestureRecognizer:tapGestureRecognizerForLabel];
    invitationNoticeLabel.userInteractionEnabled = YES;
    
    _invitationNoticeLabel = invitationNoticeLabel;
    return _invitationNoticeLabel;
}

- (UIToolbar*)fieldToolbar {
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    
    LoginSegmentedControlButton * previousNextControl = [[LoginSegmentedControlButton alloc] initWithItems:@[ @"Previous", @"Next" ]];
    
    if ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        
        [toolbar setBarStyle:UIBarStyleBlackTranslucent];
        previousNextControl.tintColor = [UIColor blackColor];
        
    } else {
        
        toolbar.translucent = YES;
        toolbar.backgroundColor = [UIColor whiteColor];
        toolbar.tintColor = kTintColour;
        
        previousNextControl.tintColor = [UIColor grayColor];
        
        _toolbarBottomBorder = [CALayer layer];
        _toolbarBottomBorder.backgroundColor = [RGBCOLOR(204, 204, 204) CGColor];
        [toolbar.layer insertSublayer:_toolbarBottomBorder atIndex:100];
    }
    
    previousNextControl.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [previousNextControl addTarget:self action:@selector(didTapPreviousNextFormElement:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * previousNextItem = [[UIBarButtonItem alloc] initWithCustomView:previousNextControl];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard:)];
    
    [toolbar setItems:@[previousNextItem, flexButton, doneButton]];
    
    _fieldToolbar = toolbar;
    
    return _fieldToolbar;
}

- (void)didTapPreviousNextFormElement:(id)sender {
    LoginSegmentedControlButton * segmentedControl = (LoginSegmentedControlButton*)sender;
    LoginSegmentedControlButtonLastTouch lastTouch = segmentedControl.lastTouch;
    
    [self.textFields sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [@(((UITextField*)obj1).tag) compare:@(((UITextField*)obj2).tag)];
    }];
    NSInteger indexOfField = [self.fieldOrder indexOfObject:@(self.selectedTextField.tag)];
    
    if(lastTouch == LoginSegmentedControlButtonLastTouchPrevious) {
        if(indexOfField == 0) { // First
            return;
        }
        [self.textFields[(indexOfField - 1)] becomeFirstResponder];
        
    } else if(lastTouch == LoginSegmentedControlButtonLastTouchNext) {
        if(indexOfField == ([self.textFields count] - 1)) { // Last
            return;
        }
        [self.textFields[(indexOfField + 1)] becomeFirstResponder];
    }
}

- (UIButton*)blackButton {
    
    // CGRectMake(((self.view.frame.size.width - 30) / 2) + 20.0f, 8, ((self.view.frame.size.width - 30) / 2), 33.0f)
    
    UIButton * blackButton = [[UIButton alloc] init]; // CGRectMake(8.0f, 8.0f, (self.view.frame.size.width / 2) - 12.0f, 33.0f)
    blackButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [blackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
     
        blackButton.titleLabel.shadowOffset = CGSizeMake(0, -1.0f);
        [blackButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        UIImage * backgroundImageForOrangeButton = [[UIImage imageNamed:@"login-register-black-button"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 11, 9, 9)];
        [blackButton setBackgroundImage:backgroundImageForOrangeButton forState:UIControlStateNormal];
        
    } else {
        blackButton.layer.cornerRadius = 4.0f;
        blackButton.backgroundColor = RGBCOLOR(116, 116, 116);
    }
    
    _blackButton = blackButton;
    return _blackButton;
}

#pragma mark - UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.selectedTextField = textField;
    
    UIToolbar * fieldToolbar = (UIToolbar*)self.selectedTextField.inputAccessoryView;
    UIBarButtonItem * segmentedControlButtonItem = (UIBarButtonItem*)[fieldToolbar.items firstObject];
    LoginSegmentedControlButton * previousNextControl = (LoginSegmentedControlButton *)segmentedControlButtonItem.customView;
    
    [previousNextControl setEnabled:YES forSegmentAtIndex:0];
    [previousNextControl setEnabled:YES forSegmentAtIndex:1];
    
    if([self.fieldOrder indexOfObject:@(self.selectedTextField.tag)] == 0) { // First
        [previousNextControl setEnabled:NO forSegmentAtIndex:0];
        
    }
    if([self.fieldOrder indexOfObject:@(self.selectedTextField.tag)] == ([self.fieldOrder count] - 1)) { // Last
        [previousNextControl setEnabled:NO forSegmentAtIndex:1];
        
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _selectedTextField = nil;
}

#pragma mark - Keyboard related Methods
- (void)keyboardWasShown:(NSNotification*)notification {
    
    if(!_keyboardTapGestureRecognizer) {
        self.keyboardTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScrollView:)];
        [self.scrollView addGestureRecognizer:self.keyboardTapGestureRecognizer];
    }
    
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Keyboard size doesn't take into account input accessory view, which is an additional 44.0f in height
    keyboardSize.height += 44.0f;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    
    // Convert to window coordinates
    CGPoint selectedTextFieldOrigin = self.selectedTextField.frame.origin;
    selectedTextFieldOrigin = [self.selectedTextField convertPoint:selectedTextFieldOrigin toView:nil];
    
    if (!CGRectContainsPoint(aRect, selectedTextFieldOrigin) ) {
        
        // This whole mess works, don't ask me why
        CGPoint scrollPoint = CGPointZero;
        if([self isKindOfClass:[LoginRegisterDetailsViewController class]]) {
            scrollPoint = CGPointMake(0.0, -((self.selectedTextField.frame.origin.y + 20) - keyboardSize.height));
        } else {
            scrollPoint = CGPointMake(0.0, -(selectedTextFieldOrigin.y - keyboardSize.height));
        }
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    
    if(_keyboardTapGestureRecognizer) {
        [self.scrollView removeGestureRecognizer:self.keyboardTapGestureRecognizer];   
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)didTapScrollView:(id)sender {
    [self.selectedTextField resignFirstResponder];
}

@end
