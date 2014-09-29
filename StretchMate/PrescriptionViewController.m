//
//  PrescriptionViewController.m
//  StretchMate
//
//  Created by James Eunson on 23/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "PrescriptionViewController.h"
#import "ExerciseCell.h"
#import "OrangeSectionHeaderView.h"
#import "SavedExercise.h"
#import "AppDelegate.h"
#import "ExerciseDetailViewController.h"
#import "UIViewController+ToggleSidebar.h"
#import "ProgramCell.h"
#import "ProgramListingViewController.h"
#import "PrescriptionProgramViewController.h"
#import "ExersiteSessionAuthenticator.h"
#import "ExersiteHTTPClient.h"
#import "ExersiteSession.h"
#import "Program.h"
#import "PractitionerExercise.h"
#import "UIImageView+AFNetworking.h"
#import "PrescriptionProgramExerciseCell.h"
#import "ProgressHUDHelper.h"
#import "ProgramSectionHeaderView.h"

#define kPrescriptionTableViewWidth 294.0f
#define kHeaderVerticalOffset 85.0f

#define kPrescriptionCellReuseIdentifier @"prescriptionProgramCell"
#define kPrescriptionExerciseCellReuseIdentifier @"prescriptionExerciseCell"
#define kPrescriptionViewAllCellReuseIdentifier @"prescriptionViewAllCell"

@interface PrescriptionViewController ()

- (void)loadData;
- (void)refreshPrescription:(id)sender;

@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) NSArray * sectionHeaders;

@end

@implementation PrescriptionViewController

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {
        self.context = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) userManagedObjectContext];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail-stripes-bg"]];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    [_tableView registerClass:[ProgramCell class] forCellReuseIdentifier:kPrescriptionCellReuseIdentifier];
    [_tableView registerClass:[PrescriptionProgramExerciseCell class] forCellReuseIdentifier:kPrescriptionExerciseCellReuseIdentifier];
    [_tableView registerClass:[PrescriptionProgramExerciseCell class] forCellReuseIdentifier:kPrescriptionViewAllCellReuseIdentifier];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    
    self.notLoggedInView = [[PrescriptionNotLoggedInView alloc] init];
    _notLoggedInView.hidden = YES;
    _notLoggedInView.translatesAutoresizingMaskIntoConstraints = NO;
    _notLoggedInView.delegate = self;
    [self.view addSubview:_notLoggedInView];
    
    self.emptyView = [[PrescriptionEmptyView alloc] init];
    _emptyView.hidden = YES;
    _emptyView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_emptyView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_tableView, _notLoggedInView, _emptyView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:bindings]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_emptyView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_emptyView]|" options:0 metrics:nil views:bindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_notLoggedInView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_notLoggedInView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshPrescription:)];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        UIBarButtonItem * drawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toggle-sidebar-icon"] style:UIBarButtonItemStyleBordered target:self action:@selector(didToggleSidebar:)];
        self.navigationItem.leftBarButtonItem = drawerButton;
        
    } else {
        
        UIBarButtonItem * drawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toggle-sidebar-icon-ios7"] style:UIBarButtonItemStyleBordered target:self action:@selector(didToggleSidebar:)];
        self.navigationItem.leftBarButtonItem = drawerButton;
        
        self.navigationController.navigationBar.translucent = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([[ExersiteSession currentSession] isUserLoggedIn]) {
        
        self.notLoggedInView.hidden = YES;
        [self loadData];
        
    } else {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.notLoggedInView.hidden = NO;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_prescribedPrograms && [_prescribedPrograms count] > 0) {
        return [_prescribedPrograms count];
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Program header cell, view all cell and 2 or fewer exercises display immediately underneath
    if(_prescribedPrograms && [_prescribedPrograms count] > 0) {
        
        NSDictionary * programForSection = self.prescribedPrograms[section];
        
        // Practitioner Program
        if([[programForSection allKeys] containsObject:@"exercises"]) {
            return [programForSection[@"exercises"] count] + 1;
            
        } else {
            
            // Stock Program
            NSNumber * programIdentifier = @([programForSection[@"id"] intValue]);
            NSInteger exerciseCount = [[[[Program programForIdentifier:programIdentifier] exercises] allObjects] count];
            
            return exerciseCount;
        }
        
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.row == 0) {
        
        ProgramCell * cell = [self.tableView dequeueReusableCellWithIdentifier:kPrescriptionCellReuseIdentifier forIndexPath:indexPath];
        cell.programDict = self.prescribedPrograms[indexPath.section];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
        
    } else {
        
        PrescriptionProgramExerciseCell * cell = [self.tableView dequeueReusableCellWithIdentifier:kPrescriptionExerciseCellReuseIdentifier forIndexPath:indexPath];
        
        NSDictionary * programForSection = self.prescribedPrograms[indexPath.section];
        id exerciseForRow = nil;
        
        if([[programForSection allKeys] containsObject:@"exercises"])
        {
            NSArray * exercisesForSection = programForSection[@"exercises"];
            exerciseForRow = exercisesForSection[(indexPath.row - 1)];
            
        } else {
            
            NSNumber * programIdentifier = @([programForSection[@"id"] intValue]);
            exerciseForRow = [[[Program programForIdentifier:programIdentifier] exercises] allObjects][indexPath.row];
        }
        
        if([exerciseForRow isKindOfClass:[Exercise class]]) {
            
            Exercise * exercise = (Exercise*)exerciseForRow;
            
            cell.textLabel.text = exercise.nameBasic;
            cell.imageView.image = [exercise getThumbnailImage];
            
        } else if([exerciseForRow isKindOfClass:[PractitionerExercise class]]) {
            
            PractitionerExercise * exercise = (PractitionerExercise*)exerciseForRow;
            cell.textLabel.text = exercise.nameBasic;
            
            __block UITableViewCell * blockCell = cell;
            NSURLRequest * requestForPractitionerExerciseImage = [NSURLRequest requestWithURL:[NSURL URLWithString:exercise.thumb]];
            [cell.imageView setImageWithURLRequest:requestForPractitionerExerciseImage placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                blockCell.imageView.image = image;
                [blockCell setNeedsLayout];
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                NSLog(@"Unable to load image for practitioner exercise with url: %@", exercise.image);
            }];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.prescribedPrograms) {
        return self.prescribedPrograms[section][@"title"];
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
    if(indexPath.row == 0) {
        return 70.0f;
        
    } else {
        return 33.0f;
    }
//    } else {
//        return 44.0f;
//    }
}

#pragma mark - Storyboard Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
//    if([segue.identifier isEqualToString:@"PrescriptionProgramSegue"]) {
//        
//        ProgramListingViewController * listingViewController = segue.destinationViewController;
//        listingViewController.selectedProgram = sender;
//        
//    } else
    
    if([segue.identifier isEqualToString:@"PrescriptionPrescribedProgramSegue"]) {

        NSDictionary * params = (NSDictionary*)sender;
        PrescriptionProgramViewController * prescribedViewController = segue.destinationViewController;
        prescribedViewController.selectedProgram = params[@"program"];
        prescribedViewController.programIndex = [params[@"index"] integerValue];
        
    } else if([segue.identifier isEqualToString:@"PrescriptionLoginSegue"]) {
        
        UINavigationController * navController = segue.destinationViewController;
        LoginViewController * loginViewController = [navController.viewControllers firstObject];
        loginViewController.delegate = self;
    }
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0) {
        
        NSDictionary * programDict = self.prescribedPrograms[indexPath.section];
        id programItem = programDict;
        if(![[programDict allKeys] containsObject:@"exercises"]) {
            programItem = [Program programForIdentifier:@([programDict[@"id"] intValue])];
            ((Program*)programItem).timeslots = programDict[@"timeslots"]; // Add timeslot information
        }
        [self performSegueWithIdentifier:@"PrescriptionPrescribedProgramSegue" sender:@{ @"program": programItem, @"index": @(indexPath.section) }];
        
    } else {
        
//        NSArray * exercisesForSection = self.prescribedPrograms[indexPath.section][@"exercises"];
//        id exerciseForRow = exercisesForSection[(indexPath.row - 1)];
//        
//        ExerciseDetailViewController * detailViewController = [[ExerciseDetailViewController alloc] init];
//        detailViewController.selectedExercise = exerciseForRow;
//        
//        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

#pragma mark - Private Methods
- (void)loadData {
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:@"Loading Programs" withDetailsLabelText:nil];
    [loadingView show:YES];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
    [httpClient retrievePrescribedProgramsWithCompletion:^(NSArray *programs) {
//        NSLog(@"completion");
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if(programs && [programs count] > 0) {
            
            self.emptyView.hidden = YES;
            self.prescribedPrograms = programs;
            
        } else {
            
            _prescribedPrograms = nil; // For reload
            self.emptyView.hidden = NO;
        }
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.tableView reloadData];
        
        [loadingView hide:YES];
    }];
}

- (void)refreshPrescription:(id)sender {
    
    // TODO: Clear cache (also need to actually build cache into the app before that)
    [self loadData];
}

#pragma mark - PrescriptionNotLoggedInViewDelegate Methods
- (void)prescriptionNotLoggedInView:(PrescriptionNotLoggedInView*)view didTapLoginButton:(UIButton*)button {
    [self performSegueWithIdentifier:@"PrescriptionLoginSegue" sender:nil];
}

#pragma mark - LoginViewControllerDelegate Methods
- (void)loginViewControllerDidLogin:(LoginViewController*)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
