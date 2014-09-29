//
//  ProgramListingViewController.m
//  StretchMate
//
//  Created by James Eunson on 16/02/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ProgramListingViewController.h"
#import "ExerciseCell.h"
#import "Exercise.h"
#import "SavedExercise.h"
#import "AppDelegate.h"
#import "ExerciseDetailViewController.h"
#import "ExerciseNowCompletingViewController.h"
#import "ExerciseNowCompletingPageViewController.h"
#import "ProgramListingHeaderView.h"
#import "UIImageView+AFNetworking.h"
#import "PractitionerExercise.h"
#import "ProgramListingStartButton.h"
#import "ProgramSectionHeaderView.h"
#import "PortraitNavigationController.h"
#import "ProgramDescriptionCell.h"
#import "ProgramAlarmCell.h"
#import "NSDate+TKCategory.h"

#define kProgramListingCellReuseIdentifier @"ProgramListingCell"
#define kProgramListingDescriptionCellReuseIdentifier @"ProgramListingDescriptionCell"
#define kProgramListingAlarmCellReuseIdentifier @"ProgramListingAlarmCell"

@interface ProgramListingViewController ()

@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) NSManagedObjectContext * userContext;

@property (nonatomic, strong) UILabel * completionTimeLabel;
@property (nonatomic, strong) UIToolbar * startHeaderView;
@property (nonatomic, strong) CALayer * startHeaderViewBottomBorderLayer;

@property (nonatomic, strong) ProgramListingHeaderView * headerView;

@property (nonatomic, strong) NSDictionary * allAlarms;
@property (nonatomic, strong) NSArray * currentProgramAlarms;

- (void)loadUserData;
- (void)didStartProgram:(id)sender;

- (BOOL)createLocalNotificationsForAlarmWithAlarmDict:(NSDictionary*)alarmDict;
- (void)destroyLocalNotificationsForAlarmWithAlarmDict:(NSDictionary*)alarmDict;

@end

@implementation ProgramListingViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.context = [delegate managedObjectContext];
        self.userContext = [delegate userManagedObjectContext];
        
        NSString * filePath = [[NSBundle mainBundle] pathForResource:@"ProgramAlarms" ofType:@"plist"];
        self.allAlarms = [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadUserData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        
        if(self.selectedProgram && [self.selectedProgram isKindOfClass:[Program class]] && [[self.selectedProgram exercises] count] == 0) {
            _tableView.contentInset = UIEdgeInsetsZero;
            _tableView.contentOffset = CGPointZero;
            
        } else {
            _tableView.contentInset = UIEdgeInsetsMake(44.0f, 0, 0, 0);
            _tableView.contentOffset = CGPointMake(0, -44.0f);
        }
    }
    
    if(_currentProgramAlarms) {
        
        // For each alarm associated with the current page, check if it is enabled, and if so, check if any alarms
        // are scheduled. If no associated alarms exist, disable the alarm. This is intended for when the user comes
        // back the evening or day(s) after the alarms have fired, and the switch has not yet been toggled back to the OFF position.
        
        for(NSDictionary * alarmDict in _currentProgramAlarms) {
            
            NSMutableDictionary * mutableProgramAlarmsEnabled = [[[AppConfig sharedConfig] programAlarmsEnabled] mutableCopy];
            NSString * identifierString = alarmDict[@"id"];
            
            if([[mutableProgramAlarmsEnabled allKeys] containsObject:identifierString]) {
             
                NSMutableArray * scheduledDates = [[NSMutableArray alloc] init];
                NSArray * scheduledNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
                
                // Find notifications associated with this alarm dict in the device's scheduled notifications list
                for(UILocalNotification * notification in scheduledNotifications) {
                    
                    NSDictionary * userInfo = [notification userInfo];
                    
                    NSInteger userInfoIdentifier = [userInfo[@"id"] integerValue];
                    NSInteger alarmDictIdentifier = [alarmDict[@"id"] integerValue];
                    
                    if(userInfoIdentifier == alarmDictIdentifier) {
                        [scheduledDates addObject:notification.fireDate];
                    }
                }
                
                // If none, we assume all alarms have already elapsed, and disable this alarm
                if(scheduledDates == 0) {
                    
                    [mutableProgramAlarmsEnabled removeObjectForKey:identifierString];
                    [[AppConfig sharedConfig] setObject:mutableProgramAlarmsEnabled forKey:kProgramAlarmsEnabled];
                    
                    [self.tableView reloadData];
                }
                
            }
        }
    }
}

- (void)loadView {
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain]; // CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height-88)
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView registerClass:[ExerciseCell class] forCellReuseIdentifier:kProgramListingCellReuseIdentifier];
    [_tableView registerClass:[ProgramDescriptionCell class] forCellReuseIdentifier:kProgramListingDescriptionCellReuseIdentifier];
    [_tableView registerClass:[ProgramAlarmCell class] forCellReuseIdentifier:kProgramListingAlarmCellReuseIdentifier];
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        _tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.tableView];
    
    self.startHeaderView = [[UIToolbar alloc] init]; // WithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [_startHeaderView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"program-start-bg"]]];
    } else {
        _startHeaderView.barTintColor = RGBCOLOR(238, 238, 238);
        
        self.startHeaderViewBottomBorderLayer = [CALayer layer];
        [_startHeaderViewBottomBorderLayer setBackgroundColor:RGBCOLOR(221, 221, 221).CGColor];
        [_startHeaderView.layer addSublayer:_startHeaderViewBottomBorderLayer];
    }
    _startHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    _startHeaderView.translucent = YES;
    
    ProgramListingStartButton * startButton = [[ProgramListingStartButton alloc] init]; // WithFrame:CGRectMake(12, 6, 169, 34)
    [startButton addTarget:self action:@selector(didStartProgram:) forControlEvents:UIControlEventTouchUpInside];
    startButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_startHeaderView addSubview:startButton];
    
    self.completionTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _completionTimeLabel.font = [UIFont systemFontOfSize:13.0f];
    _completionTimeLabel.backgroundColor = [UIColor clearColor];
    _completionTimeLabel.numberOfLines = 2;
    _completionTimeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _completionTimeLabel.textAlignment = NSTextAlignmentRight;
    _completionTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
     
        _completionTimeLabel.textColor = [UIColor whiteColor];
        _completionTimeLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.35];
        _completionTimeLabel.shadowOffset = CGSizeMake(0, -1);
        
    } else {
        
        _completionTimeLabel.textColor = RGBCOLOR(142, 142, 149);
    }
    
    if(self.selectedProgram && [self.selectedProgram isKindOfClass:[Program class]] && [self.selectedProgram completionTimeInMinutes] > 0) {
        _completionTimeLabel.text = [self.selectedProgram getCompletionTimeString];
        _completionTimeLabel.hidden = NO;
    } else {
        _completionTimeLabel.hidden = YES;
    }
    [self.startHeaderView addSubview:_completionTimeLabel];
    
    [self.view addSubview:self.startHeaderView];
    
    if(self.selectedProgram && [self.selectedProgram isKindOfClass:[Program class]] && [[self.selectedProgram exercises] count] == 0) {
        _startHeaderView.hidden = YES;
    }
    
    self.headerView = [[ProgramListingHeaderView alloc] init];
    _headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 150);
    [_headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    self.headerView.selectedProgram = _selectedProgram;
    [self.tableView setTableHeaderView:_headerView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_tableView, _startHeaderView, _headerView, startButton, _completionTimeLabel);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_startHeaderView]|" options:0 metrics:nil views:bindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_startHeaderView(44)]" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:bindings]];
    
    [_startHeaderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[startButton]-6-|" options:0 metrics:nil views:bindings]];
    [_startHeaderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[startButton]" options:0 metrics:nil views:bindings]];
    [_startHeaderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_completionTimeLabel(100)]-12-|" options:0 metrics:nil views:bindings]];
    
    [_startHeaderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_completionTimeLabel]-6-|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _startHeaderViewBottomBorderLayer.frame = CGRectMake(0, self.startHeaderView.frame.origin.y + self.startHeaderView.frame.size.height, self.view.frame.size.width, 1);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger numberOfSections = 0;
    if(_currentProgramAlarms) {
        numberOfSections += 1;
    }
    
    if([self.selectedProgram isKindOfClass:[Program class]] && [((Program*)self.selectedProgram) programDescription]) {
        numberOfSections += 1;
    }
        
    if([self.programExercises count]) {
        numberOfSections += 1;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(_currentProgramAlarms && section == 0) {
        return [_currentProgramAlarms count];
        
    } else if([self.selectedProgram isKindOfClass:[Program class]] && [((Program*)self.selectedProgram) programDescription]) {
        
        NSInteger sectionForDescription = 0;
        if(_currentProgramAlarms) {
            sectionForDescription = 1;
        }
        
        if(section == sectionForDescription) {
            return 1;
        } else {
            if(!self.programExercises) return 0;
            return [self.programExercises count];
        }
        
    } else {
        if(!self.programExercises) return 0;
        return [self.programExercises count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger sectionForDescription = 0;
    if(_currentProgramAlarms) {
        sectionForDescription = 1;
    }
    
    if(_currentProgramAlarms && indexPath.section == 0) {
    
        ProgramAlarmCell * cell = (ProgramAlarmCell*)[_tableView dequeueReusableCellWithIdentifier:kProgramListingAlarmCellReuseIdentifier forIndexPath:indexPath];
        cell.alarmDict = _currentProgramAlarms[indexPath.row];
        return cell;
        
    } else if([self.selectedProgram isKindOfClass:[Program class]] && [((Program*)self.selectedProgram) programDescription] && indexPath.section == sectionForDescription) {
        
        ProgramDescriptionCell * cell = (ProgramDescriptionCell*)[self.tableView dequeueReusableCellWithIdentifier:kProgramListingDescriptionCellReuseIdentifier forIndexPath:indexPath];
        cell.program = self.selectedProgram;
        return cell;
        
    } else {
     
        ExerciseCell *cell = (ExerciseCell*)[self.tableView dequeueReusableCellWithIdentifier:kProgramListingCellReuseIdentifier forIndexPath:indexPath];
        
        id exercise = self.programExercises[indexPath.row];
        
        Exercise * castExercise = (Exercise*)self.programExercises[indexPath.row];
        cell.textLabel.text  = castExercise.nameBasic;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ · %@", castExercise.typesString, [castExercise durationString]];
        
        if([exercise isKindOfClass:[Exercise class]]) {
            
            if([self.savedExercises indexOfObject: castExercise.identifier] != NSNotFound) {
                cell.starView = [[ExerciseStarView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-kStarViewWidth, 0, kStarViewWidth, kStarViewWidth) size:StarViewSizeSmall color:StarBackgroundColorOrange];
            } else {
                if(cell.starView) [cell.starView removeFromSuperview];
            }
            cell.imageView.image = [castExercise getThumbnailImage];
            
        } else {
            
            PractitionerExercise * practitionerExercise = (PractitionerExercise*)exercise;
            
            __block ExerciseCell * blockCell = cell;
            [cell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:practitionerExercise.thumb]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                
                blockCell.imageView.image = image;
                [blockCell setNeedsLayout];
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                NSLog(@"failure: %@", [error localizedDescription]);
            }];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger sectionForDescription = 0;
    if(_currentProgramAlarms) {
        sectionForDescription = 1;
    }
    
    if(_currentProgramAlarms && indexPath.section == 0) {
        return [ProgramAlarmCell heightForCellWithAlarmDict:_currentProgramAlarms[indexPath.row]];
        
    } else if([self.selectedProgram isKindOfClass:[Program class]] && [((Program*)self.selectedProgram) programDescription] && indexPath.section == sectionForDescription) {
        
        return [ProgramDescriptionCell heightWithProgram:self.selectedProgram];
        
    } else {
        return 55.0f;
    }
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSInteger sectionForDescription = 0;
    if(_currentProgramAlarms) {
        sectionForDescription = 1;
    }
    
    if(_currentProgramAlarms && section == 0) {
        return @"Program Alarms";
    } else if([self.selectedProgram isKindOfClass:[Program class]] && [((Program*)self.selectedProgram) programDescription] && section == sectionForDescription) {
        return @"Program Description"; 
    } else {
        return @"Program Exercises";
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ProgramSectionHeaderView * headerView = [[ProgramSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 23)];
    headerView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return headerView;
}

#pragma mark - Property Override Methods
- (void)setSelectedProgram:(id)selectedProgram {
    _selectedProgram = selectedProgram;
    
    if([_selectedProgram isKindOfClass:[Program class]]) {
        self.programExercises = [[self.selectedProgram exercises] allObjects];
        
        Program * selectedProgramProgram = (Program*)_selectedProgram;
        if([[self.allAlarms allKeys] containsObject:[selectedProgramProgram.identifier stringValue]]) {
//            NSLog(@"alarms found for current program");
            
            self.currentProgramAlarms = _allAlarms[[selectedProgramProgram.identifier stringValue]];
        }
        
    } else {
        self.programExercises = self.selectedProgram[@"exercises"];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Private Methods
- (void)loadUserData {
    
//    NSLog(@"ExercisesListingViewController: loadUserData");
    
    NSError * error = nil;
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SavedExercise"];
    NSArray * results = [self.userContext executeFetchRequest:fetchRequest error:&error];
    
    // Store only the identifiers of saved exercises in a visible array, to reduce comparison times
    NSMutableArray * savedIdentifiers = [[NSMutableArray alloc] init];
    for(SavedExercise * savedExercise in results) {
        [savedIdentifiers addObject:savedExercise.exerciseIdentifier];
    }
    self.savedExercises = savedIdentifiers;
}

- (void)didStartProgram:(id)sender {
    
    ExerciseNowCompletingPageViewController * nowCompletingViewController = [[ExerciseNowCompletingPageViewController alloc] initWithProgramExercises:self.programExercises];
    PortraitNavigationController * navController = [[PortraitNavigationController alloc] initWithRootViewController:nowCompletingViewController];
    nowCompletingViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController animated:YES completion:nil];
}

- (BOOL)createLocalNotificationsForAlarmWithAlarmDict:(NSDictionary*)alarmDict {
    
    NSDate * now = [NSDate date];
//    TKDateInformation dateInformation =  [now dateInformation];
    
//    NSInteger currentDaySeconds = (dateInformation.hour * (60 * 60)) + (dateInformation.minute * 60);
    NSTimeInterval cutoffForAlarm = (double)(18 * (60 * 60));
//
//    if(currentDaySeconds > cutoffForAlarm) {
//        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Already past the last alarm time for today. Please try again tomorrow." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alertView show];
//        return;
//    }
    
    NSTimeInterval timeIntervalForAlarm = [alarmDict[@"period"] doubleValue];
	NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    
    NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    
    NSMutableArray * scheduledAlarmDates = [[NSMutableArray alloc] init];
    NSDate * lastAlarmDate = nil;
    while(true) {
        
        NSDate * alarmDate = nil;
        if(lastAlarmDate) {
            alarmDate = [lastAlarmDate dateByAddingTimeInterval:timeIntervalForAlarm];
        } else {
            alarmDate = [now dateByAddingTimeInterval:timeIntervalForAlarm];
        }
        NSString * dateString = [dateFormatter stringFromDate:alarmDate];
        
        TKDateInformation dateInformationForAlarmDate = [alarmDate dateInformation];
        NSInteger alarmSeconds = (dateInformationForAlarmDate.hour * (60 * 60)) + (dateInformationForAlarmDate.minute * 60);
        
        if(alarmSeconds < cutoffForAlarm) {
//            NSLog(@"%@", dateString);
            lastAlarmDate = alarmDate;
            
            [scheduledAlarmDates addObject:alarmDate];
            
        } else {
            break;
        }
    }
    
    if([scheduledAlarmDates count] == 0) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Based on the current time, there are no more reminders available for today. Please try again tomorrow." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        return NO;
    }
    
    for(NSDate * scheduledAlarmDate in scheduledAlarmDates) {
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        [localNotification setFireDate:scheduledAlarmDate];
        [localNotification setTimeZone:[NSTimeZone defaultTimeZone]];
        [localNotification setUserInfo:alarmDict];
        
        // Setup alert notification
        [localNotification setAlertBody:alarmDict[@"reminderText"]];
        [localNotification setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber] + 1];
        [localNotification setSoundName:UILocalNotificationDefaultSoundName];
        
        // Schedule the notification
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
    return YES;
}

- (void)destroyLocalNotificationsForAlarmWithAlarmDict:(NSDictionary*)alarmDict {
    
    // Store separately so we aren't mutating the active notification set while iterating
    NSMutableArray * notificationsToBeCancelled = [[NSMutableArray alloc] init];
    
    NSArray * notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for(UILocalNotification * notification in notifications) {
        
        NSDictionary * userInfo = [notification userInfo];
        
        NSInteger userInfoIdentifier = [userInfo[@"id"] integerValue];
        NSInteger alarmDictIdentifier = [alarmDict[@"id"] integerValue];
        
        if(userInfoIdentifier == alarmDictIdentifier) {
//            NSLog(@"notification found");
            [notificationsToBeCancelled addObject:notification];
        }
    }
    
    for(UILocalNotification * notification in notificationsToBeCancelled) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
//        NSLog(@"notification cancelled");
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger sectionForDescription = 0;
    if(_currentProgramAlarms) {
        sectionForDescription = 1;
    }
    
    if(_currentProgramAlarms && indexPath.section == 0) {
        
        // Toggle alarm set value
        NSMutableDictionary * mutableProgramAlarmsEnabled = [[[AppConfig sharedConfig] programAlarmsEnabled] mutableCopy];
        
        NSDictionary * alarmDict = _currentProgramAlarms[indexPath.row];
        NSString * identifierString = alarmDict[@"id"];
        
        if([[mutableProgramAlarmsEnabled allKeys] containsObject:identifierString]) {
            
            [mutableProgramAlarmsEnabled removeObjectForKey:identifierString];
            [self destroyLocalNotificationsForAlarmWithAlarmDict:alarmDict];
            
            [[AppConfig sharedConfig] setObject:mutableProgramAlarmsEnabled forKey:kProgramAlarmsEnabled];
            [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        } else {
            
            [mutableProgramAlarmsEnabled setObject:@(YES) forKey:identifierString];
            BOOL success = [self createLocalNotificationsForAlarmWithAlarmDict:alarmDict];
            
            if(success) {
                [[AppConfig sharedConfig] setObject:mutableProgramAlarmsEnabled forKey:kProgramAlarmsEnabled];
                [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
        
    } else if([self.selectedProgram isKindOfClass:[Program class]] && [((Program*)self.selectedProgram) programDescription] && indexPath.section == sectionForDescription) {
//        NSLog(@"tapped description");
        
    } else { // Exercise
        [self performSegueWithIdentifier:@"ProgramExerciseSegue" sender:nil];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"ProgramExerciseSegue"]) {
        
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        Exercise * exercise = (Exercise*)self.programExercises[selectedRowIndex.row];
        ExerciseDetailViewController *detailViewController = [segue destinationViewController];
        
        detailViewController.selectedExercise = exercise;
        
    }
//    else if([[segue identifier] isEqualToString:@"ExerciseNowCompletingSegue"]) {
//        
//        Exercise * exercise = [self.programExercises firstObject];
//        
//        UINavigationController * destinationNavController = [segue destinationViewController];
//        ExerciseNowCompletingViewController *detailViewController = (ExerciseNowCompletingViewController*)[destinationNavController visibleViewController];
//        detailViewController.selectedExercise = exercise;
//    }
}

@end
