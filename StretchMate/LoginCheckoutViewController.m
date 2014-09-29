//
//  LoginCheckoutViewController.m
//  Exersite
//
//  Created by James Eunson on 11/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "LoginCheckoutViewController.h"
#import "LoginButtonCell.h"
#import "ShopDeliveryViewController.h"

@interface LoginCheckoutViewController ()

@end

@implementation LoginCheckoutViewController

- (void)loadView {
    [super loadView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.headerView.subHeadingLabel.text = @"Login to your Exersite account for a faster checkout or checkout as a guest.";
    
    self.stepView = [[ShopCheckoutStepView alloc] init];
    _stepView.selectedStep = ShopCheckoutStepLogin;
    [self.view addSubview:_stepView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.stepView.frame = CGRectMake(0, 0, self.view.frame.size.width, 33.0f);
    
    CGFloat heightForHeaderView = [LoginRegisterHeaderView heightForHeaderViewWithTitle:self.headerView.headingLabel.text andSubtitle:self.headerView.subHeadingLabel.text];
    self.headerView.frame = CGRectMake(0, 33.0f + 20.0f, self.view.frame.size.width, heightForHeaderView);
    
    self.tableViewBackgroundView.frame = CGRectMake(0, self.headerView.frame.origin.y + self.headerView.frame.size.height, self.view.frame.size.width, 234.0f);
    self.tableView.frame = CGRectMake(0, self.headerView.frame.origin.y + self.headerView.frame.size.height, self.view.frame.size.width, 234.0f);
    
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
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0)) {
        return 44.0f;
    }
    return 52.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0)) {
        
        UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell;
        
    } else if(indexPath.section == 1 && indexPath.row == 1) {
        
        LoginButtonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kLoginButtonCellIdentifier forIndexPath:indexPath];
        cell.type = LoginButtonCellTypeCheckoutAsGuest;
        cell.textLabel.text = @"Checkout as Guest";
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate Methods
- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0) {
        [self startAuthentication];
    } else {
        ShopDeliveryViewController * controller = [[ShopDeliveryViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
