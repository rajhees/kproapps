//
//  ProgramsViewController.m
//  StretchMate
//
//  Created by James Eunson on 13/02/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ProgramsViewController.h"
#import "ProgramListingViewController.h"
#import "AppDelegate.h"
#import "ProgramItemCell.h"
#import "Program.h"
#import "UIViewController+ToggleSidebar.h"
#import "ProgressHUDHelper.h"
#import "ExersiteHTTPClient.h"
#import "ProgramItemCleanCell.h"
#import "ProgramSectionHeaderView.h"
#import "ProgramCell.h"
#import "ExersiteSession.h"
#import "UIImageView+AFNetworking.h"
#import "Exercise.h"

#define kProgramCellReuseIdentifier @"ProgramItemCell"
#define kProgramSectionHeaderReuseIdentifier @"ProgramSectionHeader"

#define kProgramTableViewCellReuseIdentifier @"ProgramCell"

@interface ProgramsViewController ()
- (void)loadData;
- (void)loadPrescribedPrograms;

- (void)didChangeSegment:(id)sender;

@property (nonatomic, strong) NSArray * prescribedPrograms;

@end

@implementation ProgramsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        self.context = [delegate managedObjectContext];
        
        // Override default tab bar item
        UIImage *programsIcon = [UIImage imageNamed:@"programs-icon"];
        UITabBarItem *programsTabBarItem = [[UITabBarItem alloc]
                                             initWithTitle:@"Programs" image:programsIcon tag:1];
        [programsTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"programs-icon-selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"programs-icon"]];
        [self setTabBarItem:programsTabBarItem];
        
        self.filteredPrograms = [[NSMutableArray alloc] init];
        
        [self loadData];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"detail-stripes-bg"]];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;        
    }
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _collectionView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    
    [self.collectionView registerClass:[ProgramItemCleanCell class] forCellWithReuseIdentifier:kProgramCellReuseIdentifier];
    [self.collectionView registerClass:[ProgramSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kProgramSectionHeaderReuseIdentifier];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:_collectionView];
    
    self.searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"Search Programs";
    _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    _searchBar.translucent = YES;

    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
	[self.searchController setDelegate:self];
	[self.searchController setSearchResultsDataSource:self];
	[self.searchController setSearchResultsDelegate:self];
    
//    self.searchDisplayController.searchBar.placeholder = @"Search Programs";
//    self.searchDisplayController.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
//    self.searchDisplayController.searchBar.translucent = YES;
    
    [self.view addSubview:_searchBar];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_tableView registerClass:[ProgramCell class] forCellReuseIdentifier:kProgramTableViewCellReuseIdentifier];
    [_tableView setScrollsToTop:YES];
    
    _tableView.hidden = YES;
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        _tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
        _tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    [self.view addSubview: _tableView];
    
    UISegmentedControl * control = [[UISegmentedControl alloc] initWithItems:@[ @"A", @"B" ]];
    control.frame = CGRectMake(0, 0, 70, 30);
    control.segmentedControlStyle = UISegmentedControlStyleBar;
    control.tintColor = kTintColour;

    [control setImage:[UIImage imageNamed:@"programs-selector-collection-ios7"] forSegmentAtIndex:0];
    [control setImage:[UIImage imageNamed:@"programs-selector-list-ios7"] forSegmentAtIndex:1];
    [control setSelectedSegmentIndex:0];
    [control addTarget:self action:@selector(didChangeSegment:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem * controlItem = [[UIBarButtonItem alloc] initWithCustomView:control];
    [self.navigationItem setRightBarButtonItem:controlItem];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_collectionView, _searchBar, _tableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_searchBar]|" options:0 metrics:nil views:bindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_searchBar]" options:0 metrics:nil views:bindings]];
    
    [self.view bringSubviewToFront:_searchBar];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    if([[ExersiteSession currentSession] isUserLoggedIn] && [[ExersiteSession currentSession] userType] == ExersiteSessionUserTypePatient) {
//        [self loadPrescribedPrograms];
//    }
}

#pragma mark - Private Methods
- (void)didChangeSegment:(id)sender {
    
    UISegmentedControl * control = (UISegmentedControl *)sender;
    
    if(control.selectedSegmentIndex == 0) {
        
        self.collectionView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.collectionView.hidden = YES;
        self.tableView.hidden = NO;
    }
}

- (void)loadData {
    
    NSError * error = nil;
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Program"];
    
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:@[ sortDescriptor ]];
    
    self.programs = [self.context executeFetchRequest:fetchRequest error:&error];
}

- (void)loadPrescribedPrograms {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    self.refreshItem.enabled = NO;
    
    ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
    [httpClient retrievePrescribedProgramsWithCompletion:^(NSArray *programs) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if(programs) {
            self.prescribedPrograms = programs;
        }
//        self.refreshItem.enabled = YES;
//        [self evaluateViewVisibility];
//        [self.prescribedTableView reloadData];
        
        [self.collectionView reloadData];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ProgramListingSegue"]) {
        
        Program * selectedProgram = (Program*)sender;
        ProgramListingViewController *detailViewController = [segue destinationViewController];
        detailViewController.selectedProgram = selectedProgram;
    }
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
//    if(self.prescribedPrograms && [self.prescribedPrograms count] > 0) {
//        return 2;
//    } else {
//        return 1;
//    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(self.prescribedPrograms && [self.prescribedPrograms count] > 0) {
        if(section == 0) {
            return [self.prescribedPrograms count];
        } else {
            return [self.programs count];
        }
    } else {
        return [self.programs count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ProgramItemCleanCell * cell = (ProgramItemCleanCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kProgramCellReuseIdentifier forIndexPath:indexPath];
    
    // Displaying programs prescribed by the practitioner, NYI fully, disabled for 1.0 release
    if(self.prescribedPrograms && [self.prescribedPrograms count] > 0 && indexPath.section == 0) {
        
        NSDictionary * programDict = self.prescribedPrograms[indexPath.row];
        cell.itemTitleString = programDict[@"title"];
        
        if([[programDict allKeys] containsObject:@"exercises"]) {
            
            if([programDict[@"exercises"] count] == 0 || [programDict[@"exercises"] count] > 1) {
                cell.itemExercisesContainerLabel.text = [NSString stringWithFormat:@"%d exercises", [programDict[@"exercises"] count]];
            } else {
                cell.itemExercisesContainerLabel.text = [NSString stringWithFormat:@"%d exercise", [programDict[@"exercises"] count]];
            }
            cell.overlayInsetView.hidden = YES;
            
            NSArray * exercises = programDict[@"exercises"];
            id firstExercise = [exercises firstObject];
            
            if([firstExercise isKindOfClass:[Exercise class]]) {
                Exercise * firstObjectExercise = (Exercise*)firstExercise;
                [cell.itemImageView setImage:[[firstObjectExercise getImages] firstObject]];
                
            } else {
                NSDictionary * firstObjectDict = (NSDictionary*)firstExercise;
                [cell.itemImageView setImageWithURL:[NSURL URLWithString:firstObjectDict[@"thumb"]]];
            }
            
            cell.itemImageView.frame = CGRectMake(0, 0, kProgramCellWidth, kProgramCellWidth - 44.0f);
            
        } else {
            
            Program * stockProgram = [Program programForIdentifier: @([programDict[@"id"] integerValue])];
            
            cell.overlayInsetView.hidden = NO;
            cell.itemExercisesContainerLabel.text = [stockProgram getExerciseString];
            cell.overlayInsetViewLabel.text = [stockProgram getShortCompletionTimeString];
            
            cell.itemImageView.image = [stockProgram getOverviewImageWithSize:CGSizeMake(kProgramCellWidth, kProgramCellWidth - 44) type:OverviewImageTypeThumbnail];
            cell.itemImageView.frame = CGRectMake(0, 0, kProgramCellWidth, kProgramCellWidth - 44.0f);
            
        }
//        cell.itemExercisesContainerLabel.text = [NSString stringWithFormat:@""];
        
    } else { // Displaying stock programs
     
        Program * itemProgram = self.programs[indexPath.row];
        cell.itemTitleString = itemProgram.title;

        cell.overlayInsetViewLabel.text = [itemProgram getShortCompletionTimeString];
        
        if([[itemProgram.title lowercaseString] rangeOfString:[@"Drink Water" lowercaseString]].location != NSNotFound) {
            
            cell.overlayInsetView.hidden = YES;
            cell.itemImageView.image = [UIImage imageNamed:@"programs-drink-water.jpg"];
            cell.itemExercisesContainerLabel.text = @"No Exercises";
            
        } else {
            
            cell.overlayInsetView.hidden = NO;
            cell.itemImageView.image = [itemProgram getOverviewImageWithSize:CGSizeMake(kProgramCellWidth, kProgramCellWidth - 44) type:OverviewImageTypeThumbnail];
            cell.itemExercisesContainerLabel.text = [itemProgram getExerciseString];
        }
        cell.itemImageView.frame = CGRectMake(0, 0, kProgramCellWidth, kProgramCellWidth - 44.0f);
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.frame.size.width, 23);
}

- (id)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if([kind isEqual:UICollectionElementKindSectionHeader]) {
        
        ProgramSectionHeaderView * headerView = (ProgramSectionHeaderView*)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kProgramSectionHeaderReuseIdentifier forIndexPath:indexPath];
        
        if(self.prescribedPrograms && [self.prescribedPrograms count] > 0) {
            if(indexPath.section == 0) {
                headerView.titleLabel.text = @"Prescribed by your Practitioner";
            } else {
                headerView.titleLabel.text = @"Exersite Programs";
            }
        } else {
            headerView.titleLabel.text = @"Exersite Programs";
        }
        [headerView setNeedsLayout];
        return headerView;
    }
    
    return nil;
}

#pragma mark - UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // animate the cell user tapped on
    ProgramItemCell *cell = (ProgramItemCell*)[collectionView cellForItemAtIndexPath:indexPath];
//    cell.itemHighlightView.alpha = 1.0f;
//    [UIView animateWithDuration:0.3f
//                          delay:0
//                        options:(UIViewAnimationOptionAllowUserInteraction)
//        animations:^{
//            NSLog(@"animation start");
//            cell.itemHighlightView.alpha = 0.0f;
//        }
//        completion:^(BOOL finished){
//            NSLog(@"animation end");
//        }
//    ];
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    Program * selectedProgram = self.programs[indexPath.row];
    [self performSegueWithIdentifier:@"ProgramListingSegue" sender:selectedProgram];
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Program * itemProgram = self.programs[indexPath.row];
//    NSLog(@"heightForProgram: %f", [ProgramItemCleanCell heightForCellWithProgram:itemProgram]);
    
    return CGSizeMake(kProgramCellWidth, [ProgramItemCleanCell heightForCellWithProgram:itemProgram] + kProgramCellMarginBottom);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.searchController.searchResultsTableView) {
        return [self.filteredPrograms count];
    } else {
        return [self.programs count];
    }
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Program * itemProgram = nil;
    
    if(tableView == self.searchController.searchResultsTableView) {
        itemProgram = self.filteredPrograms[indexPath.row];
    } else {
        itemProgram = self.programs[indexPath.row];
    }
    
    ProgramCell * cell = [self.tableView dequeueReusableCellWithIdentifier:kProgramTableViewCellReuseIdentifier forIndexPath:indexPath];
    [cell setProgram:itemProgram];
    
//    cell.textLabel.text = itemProgram.title;
//    cell.imageView.image = [itemProgram getOverviewImageWithSize:CGSizeMake(55, 55) type:OverviewImageTypeNormal];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Exersite Programs"; // TODO
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ProgramSectionHeaderView * headerView = [[ProgramSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 23)];
    headerView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return headerView;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Program * itemProgram = nil;
    
    if(tableView == self.searchController.searchResultsTableView) {
        itemProgram = self.filteredPrograms[indexPath.row];
    } else {
        itemProgram = self.programs[indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"ProgramListingSegue" sender:itemProgram];
}

#pragma mark - UISearchDisplayControllerDelegate Methods
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    tableView.separatorInset = UIEdgeInsetsZero;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [_filteredPrograms removeAllObjects];
    
    NSPredicate * searchPredicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchString];
    [_filteredPrograms addObjectsFromArray:[self.programs filteredArrayUsingPredicate:searchPredicate]];
    
    return true;
}

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}


@end
