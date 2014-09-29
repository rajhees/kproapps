//
//  NotificationsViewController.m
//  StretchMate
//
//  Created by James Eunson on 23/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "NotificationsViewController.h"
#import "ExersiteHTTPClient.h"
#import "ProgressHUDHelper.h"
#import "Notification.h"
#import "NotificationCell.h"

#define kNotificationCellReuseIdentifier @"notificationCell"

@interface NotificationsViewController ()

- (void)refreshAction:(id)sender;
- (void)loadNotifications;

@end

@implementation NotificationsViewController

- (void)loadView {
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsZero;
    
    [_tableView registerClass:[NotificationCell class] forCellReuseIdentifier:kNotificationCellReuseIdentifier];
    
    [self.view addSubview:_tableView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_tableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Notifications";
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        UIBarButtonItem * drawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toggle-sidebar-icon"] style:UIBarButtonItemStyleBordered target:self action:@selector(didToggleSidebar:)];
        self.navigationItem.leftBarButtonItem = drawerButton;
        
    } else {
        
        UIBarButtonItem * drawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toggle-sidebar-icon-ios7"] style:UIBarButtonItemStyleBordered target:self action:@selector(didToggleSidebar:)];
        self.navigationItem.leftBarButtonItem = drawerButton;
        
        self.navigationController.navigationBar.translucent = NO;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
    
    [self loadNotifications];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[Notification allNotifications] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:kNotificationCellReuseIdentifier forIndexPath:indexPath];
    cell.notification = ((Notification*)[Notification allNotifications][indexPath.row]);
    
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NotificationCell heightForCellWithNotification:((Notification*)[Notification allNotifications][indexPath.row])];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
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

- (void)refreshAction:(id)sender {
    [self loadNotifications];
}

@end
