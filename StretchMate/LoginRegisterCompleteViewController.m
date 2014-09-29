//
//  LoginRegisterCompleteViewController.m
//  Exersite
//
//  Created by James Eunson on 4/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "LoginRegisterCompleteViewController.h"

@interface LoginRegisterCompleteViewController ()

- (void)doneAction:(id)sender;

@end

@implementation LoginRegisterCompleteViewController

- (void)loadView {
    [super loadView];
    
    self.headerView.hidden = YES;
    
    self.completeView = [[RegistrationCompleteView alloc] init];
    _completeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_completeView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_completeView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_completeView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_completeView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Success";
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
}

#pragma mark - Private Methods
- (void)doneAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
