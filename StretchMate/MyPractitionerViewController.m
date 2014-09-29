//
//  MyPractitionerViewController.m
//  Exersite
//
//  Created by James Eunson on 7/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "MyPractitionerViewController.h"
#import "MyPractitionerCell.h"
#import "ExersiteHTTPClient.h"
#import "ProgressHUDHelper.h"
#import "UIImageView+AFNetworking.h"
#import "NotificationCell.h"
#import "ProgramSectionHeaderView.h"

static NSString * kPractitionerCellIdentifier = @"practitionerCell";
static NSString * kNotificationCellReuseIdentifier = @"notificationCell";

@interface MyPractitionerViewController ()

- (void)refreshAction:(id)sender;
- (void)loadData;
- (void)loadNotifications;

@property (nonatomic, strong) NSDictionary * practitionerDetails;

@end

@implementation MyPractitionerViewController

- (void)loadView {
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsZero;
    
    [_tableView registerClass:[MyPractitionerCell class] forCellReuseIdentifier:kPractitionerCellIdentifier];
    [_tableView registerClass:[NotificationCell class] forCellReuseIdentifier:kNotificationCellReuseIdentifier];
    
    [self.view addSubview:_tableView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_tableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        UIBarButtonItem * drawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toggle-sidebar-icon"] style:UIBarButtonItemStyleBordered target:self action:@selector(didToggleSidebar:)];
        self.navigationItem.leftBarButtonItem = drawerButton;
        
    } else {
        
        UIBarButtonItem * drawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toggle-sidebar-icon-ios7"] style:UIBarButtonItemStyleBordered target:self action:@selector(didToggleSidebar:)];
        self.navigationItem.leftBarButtonItem = drawerButton;
        
        self.navigationController.navigationBar.translucent = NO;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
    
    self.title = @"My Practitioner";
    
    [self loadData];
    [self loadNotifications];
}

#pragma mark - Private Methods
- (void)refreshAction:(id)sender {
    
    [self loadData];
    [self loadNotifications];
}

- (void)loadData {
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
    
    ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
    [httpClient retrievePractitionerDetailsWithCompletion:^(NSDictionary *result) {
        [loadingView hide:YES];
        
        if(result) {
            self.practitionerDetails = result;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 1;
    } else {
        return [[Notification allNotificationsFromMyPractitioner] count];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
    
        MyPractitionerCell * cell = [[MyPractitionerCell alloc] init];
        cell.practitionerDict = _practitionerDetails;
        return cell;
        
    } else {
        
        NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:kNotificationCellReuseIdentifier forIndexPath:indexPath];
        cell.notification = ((Notification*)[Notification allNotificationsFromMyPractitioner][indexPath.row]);
        return cell;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 1) {
        return @"Recent Practitioner Activity";
    }
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(section == 1) {
        ProgramSectionHeaderView * headerView = [[ProgramSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kProgramSectionHeaderHeight)];
        headerView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        return headerView;
        
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 1) {
        return kProgramSectionHeaderHeight;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        if(_practitionerDetails) {
            return [MyPractitionerCell heightWithPractitionerDict:_practitionerDetails];
        } else {
            return 66.0f;
        }
        
    } else {
        return [NotificationCell heightForCellWithNotification:((Notification*)[Notification allNotificationsFromMyPractitioner][indexPath.row])];
    }
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Private Methods
- (void)loadNotifications {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
    
    ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
    [httpClient retrieveNotificationsWithCompletion:^(NSDictionary *result) {
        
        [loadingView hide:YES];
        
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}


@end
