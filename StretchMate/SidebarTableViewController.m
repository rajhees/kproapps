//
//  SidebarTableViewController.m
//  Exersite
//
//  Created by James Eunson on 26/06/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "SidebarTableViewController.h"
#import "SidebarCell.h"
#import "AppDelegate.h"
#import "NSObject+PerformBlockAfterDelay.h"
#import "ProgressHUDHelper.h"
#import "ExersiteDrawerController.h"
#import "ExersiteHTTPClient.h"
#import "ExersiteSession.h"
#import "IASKAppSettingsViewController.h"
#import "SettingsDelegate.h"
#import "ProgramSectionHeaderView.h"
#import "SidebarNotificationCell.h"
#import "NotificationsViewController.h"
#import "Notification.h"
#import "SidebarEmptyNotificationCell.h"

#define kSidebarUserCellReuseIdentifier @"sidebarUserCell"
#define kSidebarCellReuseIdentifier @"sidebarCell"
#define kSidebarNotificationCell @"sidebarNotificationCell"
#define kSidebarEmptyNotificationCell @"sidebarEmptyNotificationCell"

@interface SidebarTableViewController ()

@property (nonatomic, strong) SidebarUserCell * userCell;
@property (nonatomic, strong) NSNumber * prescribedProgramsNumber;

@property (nonatomic, strong, readonly) IASKAppSettingsViewController * settingsViewController;
@property (nonatomic, strong, readonly) SettingsDelegate * settingsDelegate;

@property (nonatomic, strong) CALayer * sideBorder;

- (void)retrievePrescribedExercisesCount;
- (void)retrieveNotifications;

- (void)userDidLoginOrLogout:(NSNotification*)notification;

- (void)didTapNotificationsHeader:(id)sender;

@end

@implementation SidebarTableViewController
@synthesize settingsViewController = _settingsViewController;
@synthesize settingsDelegate = _settingsDelegate;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
//        NSLog(@"init");
        
        self.prescribedProgramsNumber = @(0);
        
        // Only retrieve prescription for patient, the only user type to have one
        if([[ExersiteSession currentSession] isUserLoggedIn] && [[ExersiteSession currentSession] userType] == ExersiteSessionUserTypePatient) {
            [self retrievePrescribedExercisesCount];
        }
    }
    return self;
}

- (void)loadView {
    [super loadView];

    [self.tableView registerClass:[SidebarUserCell class] forCellReuseIdentifier:kSidebarUserCellReuseIdentifier];
    [self.tableView registerClass:[SidebarCell class] forCellReuseIdentifier:kSidebarCellReuseIdentifier];
    [self.tableView registerClass:[SidebarNotificationCell class] forCellReuseIdentifier:kSidebarNotificationCell];
    [self.tableView registerClass:[SidebarEmptyNotificationCell class] forCellReuseIdentifier:kSidebarEmptyNotificationCell];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.tableView setBackgroundColor:RGBCOLOR(201, 201, 206)];
    [self.view setBackgroundColor:RGBCOLOR(201, 201, 206)];
    
    self.sideBorder = [CALayer layer];
    _sideBorder.backgroundColor = [RGBCOLOR(201, 201, 206) CGColor];
    _sideBorder.frame = CGRectMake(self.view.frame.size.width - 1.0f, 0.0f, 1.0f, self.tableView.contentSize.height);
    [self.view.layer insertSublayer:_sideBorder atIndex:100];
    
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoginOrLogout:) name:kUserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoginOrLogout:) name:kUserDidLogoutNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self retrieveNotifications];
    
    if([[ExersiteSession currentSession] isUserLoggedIn] && [[ExersiteSession currentSession] userType] == ExersiteSessionUserTypePatient) {
        [self retrievePrescribedExercisesCount];        
    }
    
    if(![[AppConfig sharedConfig] pushNotificationDeviceTokenRecorded] && [[ExersiteSession currentSession] isUserLoggedIn]) {
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate attemptPushRegistration];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _sideBorder.frame = CGRectMake(self.view.frame.size.width - 1.0f, 0.0f, 1.0f, self.tableView.contentSize.height);
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if([[ExersiteSession currentSession] isUserLoggedIn]) {
        return 3;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 1;
        
    } else if(section == 1) {
        
        if([[ExersiteSession currentSession] isUserLoggedIn]) {
            
            if([[ExersiteSession currentSession] userType] == ExersiteSessionUserTypePatient) {
                return [kPatientAuthorizedSidebarSections count];
            } else if([[ExersiteSession currentSession] userType] == ExersiteSessionUserTypePractitioner) {
                return [kPractitionerAuthorizedSidebarSections count];
            } else if([[ExersiteSession currentSession] userType] == ExersiteSessionUserTypeUser) {
                return [kUserAuthorizedSidebarSections count];
            }
            
        } else {
            return [kSidebarSections count];
        }
        
    } else {
        
        if([Notification allNotifications] && [[Notification allNotifications] count] > 0) {
            return MIN(5, [[Notification allNotifications] count]);
        } else {
            return 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        
        self.userCell = (SidebarUserCell*)[tableView dequeueReusableCellWithIdentifier:kSidebarUserCellReuseIdentifier forIndexPath:indexPath];
        
        _userCell.delegate = self;
        return _userCell;
        
    } else if(indexPath.section == 1) {
        
        NSString * titleForSection = nil;
        if([[ExersiteSession currentSession] isUserLoggedIn]) {
            
            if([[ExersiteSession currentSession] userType] == ExersiteSessionUserTypePatient) {
                titleForSection = kPatientAuthorizedSidebarSections[indexPath.row];
            } else if([[ExersiteSession currentSession] userType] == ExersiteSessionUserTypePractitioner) {
                titleForSection = kPractitionerAuthorizedSidebarSections[indexPath.row];
            } else if([[ExersiteSession currentSession] userType] == ExersiteSessionUserTypeUser) {
                titleForSection = kUserAuthorizedSidebarSections[indexPath.row];
            }
            
        } else {
            titleForSection = kSidebarSections[indexPath.row];
        }
        
        SidebarCell *cell = (SidebarCell*)[tableView dequeueReusableCellWithIdentifier:kSidebarCellReuseIdentifier forIndexPath:indexPath];
        
        cell.titleForSection = titleForSection;
        
        if([[ExersiteSession currentSession] isUserLoggedIn] && [indexPath row] == 2 && [[ExersiteSession currentSession] userType] == ExersiteSessionUserTypePatient) {
            cell.badgeNumber = [self.prescribedProgramsNumber stringValue];
        } else {
            cell.accessoryView = nil;
        }
        
        NSString * humanReadableName = kHumanReadableSectionNames[titleForSection];
        cell.textLabel.text = humanReadableName;
        
        return cell;
        
    } else {
        
        if([Notification allNotifications] && [[Notification allNotifications] count] > 0) {
         
            SidebarNotificationCell * cell = (SidebarNotificationCell*)[self.tableView dequeueReusableCellWithIdentifier:kSidebarNotificationCell forIndexPath:indexPath];
            
            Notification * notification = [Notification allNotifications][indexPath.row];
            cell.notification = notification;
            
            return cell;
            
        } else {
            
            SidebarEmptyNotificationCell * cell = (SidebarEmptyNotificationCell*)[self.tableView dequeueReusableCellWithIdentifier:kSidebarEmptyNotificationCell forIndexPath:indexPath];
            
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if(section == 2) {
        return 30.0f;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0 && indexPath.section == 0) {
        return 65.0f;
        
    } else if(indexPath.section == 1) {
        return 44.0f;
        
    } else { // Notifications

        if([Notification allNotifications] && [[Notification allNotifications] count] > 0) {
            return [SidebarNotificationCell heightForNotificationCellWithNotification:[Notification allNotifications][indexPath.row]];
        } else {
            return 44.0f;
        }
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(section == 2) {
        
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            
            UIImageView * headerBackgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"sidebar-header-bg"] resizableImageWithCapInsets:UIEdgeInsetsZero]];
            headerBackgroundImageView.frame = CGRectMake(0, 0, tableView.frame.size.width, 30);
            [headerView addSubview:headerBackgroundImageView];
            
            UILabel * labelForHeader = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width-10, 30)];
            labelForHeader.textColor = RGBCOLOR(204, 204, 204);
            labelForHeader.shadowColor = RGBCOLOR(0, 0, 0);
            labelForHeader.shadowOffset = CGSizeMake(0, -1.0f);
            labelForHeader.font = [UIFont boldSystemFontOfSize:13.0f];
            labelForHeader.text = [[self tableView:tableView titleForHeaderInSection:section] uppercaseString];
            labelForHeader.backgroundColor = [UIColor clearColor];
            [headerView addSubview:labelForHeader];
            
            return headerView;
            
        } else {
            
            ProgramSectionHeaderView * headerView = [[ProgramSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30.0f)];
            headerView.titleLabel.text = [[self tableView:tableView titleForHeaderInSection:section] uppercaseString];
            
            // Only display view all button if there are notifications to view
            if([Notification allNotifications] && [[Notification allNotifications] count] > 0) {
                
                headerView.actionLabel.text = @"View all";
                headerView.actionLabel.hidden = NO;
                headerView.userInteractionEnabled = YES;
                
                UIButton * headerViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30.0f)];
                [headerViewButton addTarget:self action:@selector(didTapNotificationsHeader:) forControlEvents:UIControlEventTouchUpInside];
                [headerView addSubview:headerViewButton];
                [headerView bringSubviewToFront:headerViewButton];
            }
            
            return headerView;
        }
        
    } else {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 2) {
        return @"Notifications";
    }
    return nil;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 2 && !([Notification allNotifications] && [[Notification allNotifications] count] > 0)) {
        cell.backgroundColor = [UIColor clearColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"didSelectRowAtIndexPath");
    
    if(indexPath.section != 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    ExersiteDrawerController * drawerController = (ExersiteDrawerController*)delegate.window.rootViewController;
    
    NSString * titleForSection = nil;
    if([[ExersiteSession currentSession] isUserLoggedIn]) {
        
        if([[ExersiteSession currentSession] userType] == ExersiteSessionUserTypePatient) {
            titleForSection = kPatientAuthorizedSidebarSections[indexPath.row];
        } else if([[ExersiteSession currentSession] userType] == ExersiteSessionUserTypePractitioner) {
            titleForSection = kPractitionerAuthorizedSidebarSections[indexPath.row];
        } else if([[ExersiteSession currentSession] userType] == ExersiteSessionUserTypeUser) {
            titleForSection = kUserAuthorizedSidebarSections[indexPath.row];
        }
        
    } else {
        titleForSection = kSidebarSections[indexPath.row];
    }
    
    if([titleForSection isEqualToString:@"exercises"]) {
        drawerController.centerViewController = drawerController.exercisesNavigationController;
        
    } else if([titleForSection isEqualToString:@"programs"]) {
        drawerController.centerViewController = drawerController.programsNavigationController;
        
    } else if([titleForSection isEqualToString:@"prescription"]) {
        drawerController.centerViewController = drawerController.prescriptionNavigationController;
        
    } else if([titleForSection isEqualToString:@"shop"]) {
        drawerController.centerViewController = drawerController.shopNavigationController;
        
    } else if([titleForSection isEqualToString:@"mypractitioner"]) {
        drawerController.centerViewController = drawerController.myPractitionerNavController;
        
    } else if([titleForSection isEqualToString:@"myexercises"]) {
        drawerController.centerViewController = drawerController.myExercisesNavController;
        
    } else if([titleForSection isEqualToString:@"settings"]) {

        UINavigationController * settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:self.settingsViewController];
        drawerController.centerViewController = settingsNavigationController;
        settingsNavigationController.navigationBar.translucent = NO;
    }
    
    [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - Private Methods
- (void)userDidLoginOrLogout:(NSNotification*)notification {
    [_userCell.userButton updateUserInformation];
    [self.tableView reloadData];
}

- (void)retrievePrescribedExercisesCount {
    
    ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
    [httpClient retrievePrescribedProgramsWithCompletion:^(NSArray *programs) {
        self.prescribedProgramsNumber = @([[programs firstObject][@"incompleteTimes"] integerValue]);
        
        // Reload prescription cell
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:2 inSection:1] ] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)retrieveNotifications {
    // If patient, should attempt retrieve user notifications
    if([[ExersiteSession currentSession] isUserLoggedIn] && [[ExersiteSession currentSession] userType] != ExersiteSessionUserTypeUser) {
        
        ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
        [httpClient retrieveNotificationsWithCompletion:^(NSDictionary *result) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
    }
}

- (void)didTapNotificationsHeader:(id)sender {
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    ExersiteDrawerController * drawerController = (ExersiteDrawerController*)delegate.window.rootViewController;
    NotificationsViewController * notificationsController = [[NotificationsViewController alloc] init];;
    
    UINavigationController * settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:notificationsController];
    drawerController.centerViewController = settingsNavigationController;
    settingsNavigationController.navigationBar.translucent = NO;
    
    [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.destructiveButtonIndex == buttonIndex) {
        
        [[ExersiteSession currentSession] destroySession];
        [self.tableView reloadData];
        
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        ExersiteDrawerController * drawerController = (ExersiteDrawerController*)delegate.window.rootViewController;
        
        drawerController.centerViewController = drawerController.exercisesNavigationController;
        [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
    [_userCell.userButton deselectUserButton];    
}

#pragma mark - SidebarCellDelegate
- (void)userSidebarCell:(SidebarUserButton*)cell didTapUserButton:(UIButton*)userButton {
    
    if([[ExersiteSession currentSession] isUserLoggedIn]) {
        
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log Out" otherButtonTitles: nil];
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [sheet showInView: delegate.window.rootViewController.view];
        
    } else {
        
        [self performSegueWithIdentifier:@"SidebarLoginSegue" sender:userButton];
        [self performBlock:^{
            [_userCell.userButton deselectUserButton];
        } afterDelay:0.5];
    }
}

#pragma mark - Property Override
- (IASKAppSettingsViewController*)settingsViewController {
    if(_settingsViewController) {
        return _settingsViewController;
    }
    
    _settingsViewController = [[IASKAppSettingsViewController alloc] init];
    
    _settingsViewController.delegate = self.settingsDelegate;
    _settingsViewController.showCreditsFooter = NO;
    _settingsViewController.showDoneButton = NO;
    
    UIBarButtonItem * drawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toggle-sidebar-icon-ios7"] style:UIBarButtonItemStyleBordered target:self action:@selector(didToggleSidebar:)];
    _settingsViewController.navigationItem.leftBarButtonItem = drawerButton;
    
    return _settingsViewController;
}

- (SettingsDelegate*)settingsDelegate {
    
    if(_settingsDelegate) {
        return _settingsDelegate;
    }
    _settingsDelegate = [[SettingsDelegate alloc] init];
    return _settingsDelegate;
}

#pragma mark - Storyboard Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"SidebarLoginSegue"]) {
        UINavigationController * navController = (UINavigationController*)[segue destinationViewController];
        LoginViewController *loginViewController = (LoginViewController*)[navController.viewControllers firstObject];
        loginViewController.delegate = self;
    }
}

#pragma mark - LoginControllerDelegate Methods
- (void)loginViewControllerDidLogin:(LoginViewController *)controller {
    
    [self.tableView reloadData];
    [_userCell.userButton updateUserInformation];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self retrieveNotifications];
    if([[ExersiteSession currentSession] isUserLoggedIn] && [[ExersiteSession currentSession] userType] == ExersiteSessionUserTypePatient) {
        [self retrievePrescribedExercisesCount];
    }
}

@end
