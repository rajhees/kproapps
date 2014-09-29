//
//  PrescriptionProgramViewController.m
//  Exersite
//
//  Created by James Eunson on 21/08/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "PrescriptionProgramViewController.h"
#import "Program.h"
#import "PractitionerExercise.h"
#import "Exercise.h"
#import "ExerciseCell.h"
#import "NSDate+TKCategory.h"
#import "UIImageView+AFNetworking.h"
#import "ExerciseDetailViewController.h"
#import "ExersiteHTTPClient.h"
#import "ProgramSectionHeaderView.h"
#import "PrescriptionBeginCell.h"
#import "ExerciseNowCompletingPageViewController.h"
#import "PrescriptionProgramDayEmptyView.h"
#import "PrescriptionExerciseCell.h"
#import "UIActionSheet+Blocks.h"
#import "ProgressHUDHelper.h"

static NSDateFormatter * dateFormatter = nil;
static NSDateFormatter * hourFormatter = nil;

#define kPrescribedProgramExerciseCellReuseIdentifier @"PrescribedProgramExerciseCell"
#define kPrescribedProgramBeginCellReuseIdentifier @"PrescribedProgramBeginCell"

@interface PrescriptionProgramViewController ()

@property (nonatomic, strong) UIToolbar * topToolbar;
@property (nonatomic, strong) UIButton *leftArrow;
@property (nonatomic, strong) UIButton *rightArrow;
@property (nonatomic, strong) CALayer * topToolbarBottomBorder;

@property (nonatomic, strong) NSDateFormatter * dayDateFormatter;

@property (nonatomic, strong) UIToolbar * toolbar;
@property (nonatomic, strong) UISegmentedControl * modeChangeSegmentedControl;

@property (nonatomic, strong) PrescriptionProgramDayEmptyView * dayEmptyView;

- (void)nextTimeInterval:(id)sender;
- (void)previousTimeInterval:(id)sender;

- (void)organizeExercisesByTimeslot;
- (void)reloadDay;

- (void)changeModeSegment:(id)sender;
- (void)updateFilterSegmentHighlight;

- (NSString*)dayStringForDate:(NSDate*)date;

- (void)reloadDataFromServer;
- (void)refreshAction:(id)sender;

@end

@implementation PrescriptionProgramViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        self.currentDay = [[NSDate date] timelessDate];
        self.currentDayExercises = [[OrderedDictionary alloc] init];
        self.allExercisesByDay = [[OrderedDictionary alloc] init];
        
        self.dayDateFormatter = [[NSDateFormatter alloc] init];
        _dayDateFormatter.dateFormat = @"yyyy-MM-dd";
        _dayDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; // 24h time fix
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style: UITableViewStylePlain];

    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.contentInset = UIEdgeInsetsMake(44.0f, 0, 44.0f, 0);
    [_tableView registerClass:[PrescriptionBeginCell class] forCellReuseIdentifier:kPrescribedProgramBeginCellReuseIdentifier];
    [_tableView registerClass:[PrescriptionExerciseCell class] forCellReuseIdentifier:kPrescribedProgramExerciseCellReuseIdentifier];
    
    [self.view addSubview:_tableView];
    
    self.topToolbar = [[UIToolbar alloc] init];
    _topToolbar.translucent = YES;
    _topToolbar.backgroundColor = [UIColor whiteColor];
    _topToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_topToolbar];
    
    self.topToolbarBottomBorder = [CALayer layer];
    _topToolbarBottomBorder.backgroundColor = [RGBCOLOR(203, 203, 203) CGColor];
    [self.view.layer insertSublayer:_topToolbarBottomBorder atIndex:100];
    
    self.monthYearLabel = [[UILabel alloc] init];
    _monthYearLabel.textAlignment = NSTextAlignmentCenter;
    _monthYearLabel.backgroundColor = [UIColor clearColor];
    _monthYearLabel.font = [UIFont boldSystemFontOfSize:19.0f];
    _monthYearLabel.textColor = RGBCOLOR(57, 58, 70);
    _monthYearLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[_topToolbar addSubview: self.monthYearLabel];
    
    self.leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftArrow addTarget:self action:@selector(previousTimeInterval:) forControlEvents:UIControlEventTouchUpInside];
    [_leftArrow setImage:[UIImage imageNamed:@"prescription-previous-page-icon-ios7"] forState:UIControlStateNormal];
    _leftArrow.translatesAutoresizingMaskIntoConstraints = NO;
	[_topToolbar addSubview: self.leftArrow];
    
    self.rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightArrow.translatesAutoresizingMaskIntoConstraints = NO;
    [_rightArrow addTarget:self action:@selector(nextTimeInterval:) forControlEvents:UIControlEventTouchUpInside];
    [_rightArrow setImage:[UIImage imageNamed:@"prescription-next-page-icon-ios7"] forState:UIControlStateNormal];
	[_topToolbar addSubview: self.rightArrow];
    
    self.toolbar = [[UIToolbar alloc] init];
    _toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    _toolbar.tintColor = kTintColour;
    _toolbar.translucent = YES;
    _toolbar.barTintColor = [UIColor whiteColor];
    [self.view addSubview:_toolbar];
    
    self.modeChangeSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"All", @"Day", nil]];
    _modeChangeSegmentedControl.selectedSegmentIndex = 0;
    [_modeChangeSegmentedControl addTarget:self action:@selector(changeModeSegment:) forControlEvents:UIControlEventValueChanged];
    _modeChangeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    _modeChangeSegmentedControl.tintColor = kTintColour;
    _modeChangeSegmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_toolbar addSubview:_modeChangeSegmentedControl];
    
    self.dayEmptyView = [[PrescriptionProgramDayEmptyView alloc] init];
    _dayEmptyView.hidden = YES;
    _dayEmptyView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_dayEmptyView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_topToolbar, _modeChangeSegmentedControl, _tableView, _leftArrow, _rightArrow, _monthYearLabel, _dayEmptyView, _toolbar);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_toolbar(44)]|" options:0 metrics:nil views:bindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_dayEmptyView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-44-[_dayEmptyView]-44-|" options:0 metrics:nil views:bindings]];
    
    [_toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[_modeChangeSegmentedControl]-30-|" options:0 metrics:nil views:bindings]];
    [_toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_modeChangeSegmentedControl]-6-|" options:0 metrics:nil views:bindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topToolbar]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topToolbar(44)]" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:bindings]];
    
    // Date navigation bar constraints
    [_topToolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_leftArrow]|" options:0 metrics:nil views:bindings]];
    [_topToolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_rightArrow]|" options:0 metrics:nil views:bindings]];
    [_topToolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_monthYearLabel]|" options:0 metrics:nil views:bindings]];
    [_topToolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_monthYearLabel]|" options:0 metrics:nil views:bindings]];
    [_topToolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftArrow(44)]" options:0 metrics:nil views:bindings]];
    [_topToolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightArrow(44)]|" options:0 metrics:nil views:bindings]];
    
    self.mode = PrescriptionProgramViewControllerModeAll;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadDay];
    
    if([self.selectedProgram isKindOfClass:[NSDictionary class]]) {
        self.title = self.selectedProgram[@"title"];
    } else {
        self.title = ((Program*)self.selectedProgram).title;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
    
    [self updateFilterSegmentHighlight];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadDataFromServer];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _topToolbarBottomBorder.frame = CGRectMake(0, _topToolbar.frame.origin.y + _topToolbar.frame.size.height - 1, self.view.frame.size.width, 1.0f);
}

#pragma mark - Property Override
- (void)setMode:(PrescriptionProgramViewControllerMode)mode {
    _mode = mode;
    
    if(self.mode == PrescriptionProgramViewControllerModeAll) {
        
        self.topToolbar.hidden = YES;
        self.topToolbarBottomBorder.hidden = YES;
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44.0f, 0);
        
    } else {
        
        self.topToolbar.hidden = NO;
        self.topToolbarBottomBorder.hidden = NO;
        _tableView.contentInset = UIEdgeInsetsMake(44.0f, 0, 44.0f, 0);
    }
    
    [self.tableView reloadData];
}

- (void)setSelectedProgram:(id)selectedProgram {
    _selectedProgram = selectedProgram;
    
    if([_selectedProgram isKindOfClass:[Program class]]) {
        self.programExercises = [[self.selectedProgram exercises] allObjects];
    } else {
        self.programExercises = self.selectedProgram[@"exercises"];
    }
    
    [self organizeExercisesByTimeslot];
}

#pragma mark - Private Methods
- (void)reloadDataFromServer {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
    
    ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
    [httpClient retrievePrescribedProgramsWithCompletion:^(NSArray *programs) {
//        NSLog(@"completion");
        
        if(programs) {
            NSArray * prescribedPrograms = programs;
            
            NSDictionary * programDict = prescribedPrograms[self.programIndex];
            
            if(![[programDict allKeys] containsObject:@"exercises"]) {
                id programItem = [Program programForIdentifier:@([programDict[@"id"] intValue])];
                ((Program*)programItem).timeslots = programDict[@"timeslots"]; // Add timeslot information
                self.selectedProgram = programItem;
            } else {
                self.selectedProgram = programDict;
            }
            
            [self reloadDay];
            [self.tableView reloadData];
        }
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [loadingView hide:YES];
    }];
}

- (void)refreshAction:(id)sender {
    [self reloadDataFromServer];
}

- (void)updateFilterSegmentHighlight {
    
    for (int i=0; i < [self.modeChangeSegmentedControl.subviews count]; i++) {
        if ([[self.modeChangeSegmentedControl.subviews objectAtIndex:i] isSelected] ) {
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                [[self.modeChangeSegmentedControl.subviews objectAtIndex:i] setTintColor:kLightTintColour];
            } else {
                [[self.modeChangeSegmentedControl.subviews objectAtIndex:i] setTintColor:RGBCOLOR(216, 116, 36)];
            }
        } else {
            [[self.modeChangeSegmentedControl.subviews objectAtIndex:i] setTintColor:[UIColor lightGrayColor]];
        }
    }
}

- (void)changeModeSegment:(id)sender {
//    NSLog(@"change segment");
    
    [self updateFilterSegmentHighlight];
    self.mode = self.modeChangeSegmentedControl.selectedSegmentIndex;
    
    [self reloadDay];
}

- (void)previousTimeInterval:(id)sender {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-1];
    NSDate * previousDay = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.currentDay options:0];
    
    self.currentDay = previousDay;
    [self reloadDay];
}

- (void)nextTimeInterval:(id)sender {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    NSDate * nextDay = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.currentDay options:0];
    
    self.currentDay = nextDay;
    [self reloadDay];
}

- (void)organizeExercisesByTimeslot {
    
    [_allExercisesByDay removeAllObjects];
    
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; // 24h time fix
    }
    
    if(!hourFormatter) {
        hourFormatter = [[NSDateFormatter alloc] init];
        hourFormatter.dateFormat = @"hh:mm a";
        hourFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]; // 24h time fix
    }
    
    OrderedDictionary * allExercisesByTimeslotMutable = [[OrderedDictionary alloc] init];
    
    NSArray * timeslots = nil;
    if([self.selectedProgram isKindOfClass:[Program class]]) {
        timeslots = ((Program*)self.selectedProgram).timeslots;
    } else {
        timeslots = self.selectedProgram[@"timeslots"];  
    }
    
    for(NSDictionary * timeslot in timeslots) {
        
        for(NSDictionary * timeDict in timeslot[@"times"]) {
            
            NSString * time = timeDict[@"time"];
            NSDate * timeFromDate = [dateFormatter dateFromString:time];
            
            NSString * dayStringForDate = [self dayStringForDate:timeFromDate];
            
            if(![[allExercisesByTimeslotMutable allKeys] containsObject:dayStringForDate]) {
                allExercisesByTimeslotMutable[dayStringForDate] = [[OrderedDictionary alloc] init];
            }
            OrderedDictionary * mutableDayDict = allExercisesByTimeslotMutable[dayStringForDate];
            
            NSString * hourString = [hourFormatter stringFromDate:timeFromDate];
            NSString * allExercisesDayTimeString = [NSString stringWithFormat:@"%@ - %@", dayStringForDate, hourString];
            if(![[_allExercisesByDay allKeys] containsObject:allExercisesDayTimeString]) {
                _allExercisesByDay[allExercisesDayTimeString] = [[NSMutableArray alloc] init];
            }
            
            if(![[mutableDayDict allKeys] containsObject:hourString]) {
                mutableDayDict[hourString] = [[NSMutableArray alloc] init];
            }
            NSMutableArray * exercisesForTimeslot = mutableDayDict[hourString];
            
            // Match with program exercise
            NSNumber * targetIdentifier = @([timeslot[@"exercise_id"] intValue]);
            
            for(id exercise in self.programExercises) {
                if([exercise isKindOfClass:[Exercise class]]) {
                    if([((Exercise*)exercise).identifier isEqualToNumber:targetIdentifier]) {
                        
                        NSMutableDictionary * mutableTimeDict = [timeDict mutableCopy];
                        NSMutableDictionary * timeslotWithExercise = [@{ @"hour": hourString, @"time": mutableTimeDict, @"exercise": exercise } mutableCopy];
                        [exercisesForTimeslot addObject:timeslotWithExercise];
                        
                        [_allExercisesByDay[allExercisesDayTimeString] addObject:@{ @"hour": hourString, @"timeDate": timeFromDate, @"exercise": exercise, @"time": mutableTimeDict }];
                        break;
                    }
                    
                } else if([exercise isKindOfClass:[PractitionerExercise class]]) {
                    if([((PractitionerExercise*)exercise).identifier isEqualToNumber:targetIdentifier]) {
                        
                        NSMutableDictionary * mutableTimeDict = [timeDict mutableCopy];
                        NSMutableDictionary * timeslotWithExercise = [@{ @"hour": hourString, @"time": mutableTimeDict, @"exercise": exercise } mutableCopy];
                        [exercisesForTimeslot addObject:timeslotWithExercise];
                        
                        [_allExercisesByDay[allExercisesDayTimeString] addObject:@{ @"hour": hourString, @"timeDate": timeFromDate, @"exercise": exercise, @"time": mutableTimeDict }];
                        break;
                    }
                }
            }
        }
    }
    
    self.allExercisesByTimeslot = allExercisesByTimeslotMutable;
    
//    // Sort days
//    [_allExercisesByTimeslot.array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        
//        NSString * key1 = (NSString*)obj1;
//        NSString * key2 = (NSString*)obj2;
//        
//        
//    }];
    
//    NSLog(@"finished");
}

- (void)reloadDay {
    
    NSString * dayStringForCurrentDay = [self dayStringForDate:self.currentDay];
    self.monthYearLabel.text = dayStringForCurrentDay;
    
    if([[self.allExercisesByTimeslot allKeys] containsObject:dayStringForCurrentDay]) {
        self.currentDayExercises = self.allExercisesByTimeslot[dayStringForCurrentDay];
    } else {
        self.currentDayExercises = [[OrderedDictionary alloc] init];
    }
    
    if([[self.currentDayExercises allKeys] count] == 0 && self.mode == PrescriptionProgramViewControllerModeDay) {
        self.dayEmptyView.hidden = NO;
    } else {
        self.dayEmptyView.hidden = YES;
    }
        
    
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"PrescribedExerciseSegue"]) {
        ExerciseDetailViewController * detailViewController = segue.destinationViewController;
        detailViewController.selectedExercise = sender;
    }
}

- (NSString*)dayStringForDate:(NSDate *)date {
    
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
	[format setDateFormat:@"EEEE dd/MM/yyyy"];
    
    if([date isSameDay:[NSDate date]] || [date isSameDay:[[NSDate date] dateByAddingDays:1]] || [date isSameDay:[[NSDate date] dateByAddingDays:-1]]) {
        [format setDateFormat:@"EEE"];
    }
    
    if([date isSameDay:[NSDate date]]) { // Day is today
        return [NSString stringWithFormat:@"Today (%@)", [format stringFromDate:date]];
        
    } else if([date isSameDay:[[NSDate date] dateByAddingDays:1]]) { // Day is tomorrow
        return [NSString stringWithFormat:@"Tomorrow (%@)", [format stringFromDate:date]];
        
    } else if([date isSameDay:[[NSDate date] dateByAddingDays:-1]]) { // Day is yesterday
        return [NSString stringWithFormat:@"Yesterday (%@)", [format stringFromDate:date]];
        
    } else { // Return a complete date format (eg. Friday 29 March 2013)
        return [format stringFromDate:date];
    }
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(self.mode == PrescriptionProgramViewControllerModeAll) {
        return [[self.allExercisesByDay allKeys] count];
        
    } else if(self.mode == PrescriptionProgramViewControllerModeDay) {
        return [[self.currentDayExercises allKeys] count];
        
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(self.mode == PrescriptionProgramViewControllerModeAll) {
        
        NSString * key = [self.allExercisesByDay allKeys][section];
        return [self.allExercisesByDay[key] count] + 1;
        
    } else if(self.mode == PrescriptionProgramViewControllerModeDay) {
        
        NSString * key = [self.currentDayExercises allKeys][section];
        return [self.currentDayExercises[key] count] + 1;
        
    }
    
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray * exercisesForSection = nil;
    if(self.mode == PrescriptionProgramViewControllerModeAll) {
        
        NSString * key = [self.allExercisesByDay allKeys][indexPath.section];
        exercisesForSection = self.allExercisesByDay[key];
        
    } else if(self.mode == PrescriptionProgramViewControllerModeDay) {
        
        NSString * key = [self.currentDayExercises allKeys][indexPath.section];
        exercisesForSection = self.currentDayExercises[key];
    }
    
    if(indexPath.row < ([self tableView:tableView numberOfRowsInSection:indexPath.section] - 1)) {
        
        PrescriptionExerciseCell *cell = (PrescriptionExerciseCell*)[self.tableView dequeueReusableCellWithIdentifier:kPrescribedProgramExerciseCellReuseIdentifier forIndexPath:indexPath];
        cell.timeslotDict = exercisesForSection[indexPath.row];
        
        return cell;
        
    } else {
        
        PrescriptionBeginCell *cell = (PrescriptionBeginCell*)[self.tableView dequeueReusableCellWithIdentifier:kPrescribedProgramBeginCellReuseIdentifier forIndexPath:indexPath];
        
        BOOL allCompleted = YES;
        for (NSDictionary * timeslotDict in exercisesForSection) {
            
            NSDictionary * timeDict = timeslotDict[@"time"];
            if(![timeDict[@"completed"] boolValue] || !timeDict[@"completion_time"]) {
                allCompleted = NO;
                break;
            }
        }
        
        NSDictionary * timeDictWithExercise = nil;
        @try {
            timeDictWithExercise = exercisesForSection[indexPath.row - 1];
            cell.hourString = timeDictWithExercise[@"hour"];
        }
        @catch (NSException *exception) {
//            NSLog(@"failed");
        }
        cell.allCompleted = allCompleted;
        
        return cell;
    }
}


#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NSString * key = [self.currentDayExercises allKeys][indexPath.section];
//    NSArray * exercisesForSection = self.currentDayExercises[key];
    
    NSArray * exercisesForSection = nil;
    if(self.mode == PrescriptionProgramViewControllerModeAll) {
        
        NSString * key = [self.allExercisesByDay allKeys][indexPath.section];
        exercisesForSection = self.allExercisesByDay[key];
        
    } else if(self.mode == PrescriptionProgramViewControllerModeDay) {
        
        NSString * key = [self.currentDayExercises allKeys][indexPath.section];
        exercisesForSection = self.currentDayExercises[key];
    }
    
    if(indexPath.row < ([self tableView:tableView numberOfRowsInSection:indexPath.section] - 1)) {
        
        NSDictionary * timeDictWithExercise = exercisesForSection[indexPath.row];
        id exerciseForRow = timeDictWithExercise[@"exercise"];
        
        ExerciseDetailViewController *viewController = (ExerciseDetailViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:NULL] instantiateViewControllerWithIdentifier:@"ExerciseDetailViewController"];
        viewController.selectedExercise = exerciseForRow;
        viewController.viewingFromPrescriptionProgram = YES;
        
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else {
        
        BOOL allCompleted = YES;
        for (NSDictionary * timeslotDict in exercisesForSection) {
            
            NSDictionary * timeDict = timeslotDict[@"time"];
            if(![timeDict[@"completed"] boolValue] || !timeDict[@"completion_time"]) {
                allCompleted = NO;
                break;
            }
        }
        
        if(!allCompleted) {
            
            ExerciseNowCompletingPageViewController * controller = [[ExerciseNowCompletingPageViewController alloc] initWithPrescriptionProgramExercises: exercisesForSection];
            UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:controller];
            controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(self.mode == PrescriptionProgramViewControllerModeAll) {
        
        NSString * key = [self.allExercisesByDay allKeys][section];
        return key;
        
    } else if(self.mode == PrescriptionProgramViewControllerModeDay) {
        
        NSString * key = [self.currentDayExercises allKeys][section];
        return key;
        
    }
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ProgramSectionHeaderView * headerView = [[ProgramSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 23)];
    headerView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kProgramSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray * exercisesForSection = nil;
    if(self.mode == PrescriptionProgramViewControllerModeAll) {
        
        NSString * key = [self.allExercisesByDay allKeys][indexPath.section];
        exercisesForSection = self.allExercisesByDay[key];
        
    } else if(self.mode == PrescriptionProgramViewControllerModeDay) {
        
        NSString * key = [self.currentDayExercises allKeys][indexPath.section];
        exercisesForSection = self.currentDayExercises[key];
    }
    
    if(indexPath.row < ([self tableView:tableView numberOfRowsInSection:indexPath.section] - 1)) {
        return [PrescriptionExerciseCell heightForCellWithTimeslotDict:exercisesForSection[indexPath.row]];
        
    } else {
        return 44.0f;
    }
}

@end
