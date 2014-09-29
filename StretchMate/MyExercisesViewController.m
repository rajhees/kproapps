//
//  MyExercisesViewController.m
//  Exersite
//
//  Created by James Eunson on 1/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "MyExercisesViewController.h"
#import "ExerciseCell.h"
#import "AppDelegate.h"
#import "SavedExercise.h"
#import "OrderedDictionary.h"
#import "ProgramSectionHeaderView.h"
#import "ExerciseDetailViewController.h"
#import "ExerciseType.h"
#import "Exercise.h"
#import "NSObject+PerformBlockAfterDelay.h"

#define kExerciseCellReuseIdentifier @"exerciseCell"

@interface MyExercisesViewController ()

@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) NSManagedObjectContext * userContext;

@property (nonatomic, strong) NSMutableArray * orderedAllExercises;
@property (nonatomic, strong) OrderedDictionary * exercisesByType;
@property (nonatomic, strong) OrderedDictionary * exercisesByLocation;

@property (nonatomic, strong) NSMutableArray * flatSearchResults;
@property (nonatomic, strong) OrderedDictionary * sectionedSearchResults;

- (void)toggleEdit:(id)sender;
- (void)filterDidChange:(id)sender;

- (void)updateFilterSegmentHighlight;
- (void)loadData;

@end

@implementation MyExercisesViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.context = [delegate managedObjectContext];
        self.userContext = [delegate userManagedObjectContext];
        
        self.orderedAllExercises = [[NSMutableArray alloc] init];
        self.exercisesByLocation = [[OrderedDictionary alloc] init];
        self.exercisesByType = [[OrderedDictionary alloc] init];
        
        self.flatSearchResults = [[NSMutableArray alloc] init];
        self.sectionedSearchResults = [[OrderedDictionary alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[ExerciseCell class] forCellReuseIdentifier:kExerciseCellReuseIdentifier];
    [_tableView setScrollsToTop:YES];
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
        _tableView.separatorInset = UIEdgeInsetsZero;
    }
    [self.view addSubview: _tableView];
    
    self.searchBar = [[UISearchBar alloc] init];
    _searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44.0f);
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.placeholder = @"Filter";
    _searchBar.delegate = self;
    [_tableView setTableHeaderView:_searchBar];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
	[self.searchController setDelegate:self];
	[self.searchController setSearchResultsDataSource:self];
	[self.searchController setSearchResultsDelegate:self];
    
    self.toolbar = [[UIToolbar alloc] init];
    _toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    _toolbar.translucent = YES;
    _toolbar.barTintColor = [UIColor whiteColor];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"All", @"Type", @"Location" ]];
    [_segmentedControl addTarget:self action:@selector(filterDidChange:) forControlEvents:UIControlEventValueChanged];
    _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    _segmentedControl.selectedSegmentIndex = 0;
//    _segmentedControl.selectedSegmentIndex = [[AppConfig sharedConfig] myExercisesActiveFilterType];
    _segmentedControl.tintColor = kTintColour;
    _segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [_toolbar addSubview:_segmentedControl];
    
    [self.view addSubview:_toolbar];
    
    self.emptyView = [[MyExercisesEmptyView alloc] init];
    _emptyView.translatesAutoresizingMaskIntoConstraints = NO;
    _emptyView.hidden = YES;
    [self.view addSubview:_emptyView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_tableView, _toolbar, _segmentedControl, _emptyView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:bindings]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_emptyView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_emptyView]|" options:0 metrics:nil views:bindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_toolbar]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|" options:0 metrics:nil views:bindings]];
    
    [self.toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_segmentedControl]-6-|" options:0 metrics:nil views:bindings]];
    [self.toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[_segmentedControl]-6-|" options:0 metrics:nil views:bindings]];
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)];
    
    self.title = @"My Exercises";
    
    [self updateFilterSegmentHighlight];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadData];
}

#pragma mark - Private Methods
- (void)toggleEdit:(id)sender {
    self.tableView.editing = !self.tableView.editing;
    
    if(self.tableView.editing) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEdit:)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit:)];
    }
}

- (void)filterDidChange:(id)sender {
    self.filterType = _segmentedControl.selectedSegmentIndex;
    [self updateFilterSegmentHighlight];
    
    [[AppConfig sharedConfig] setInteger:_segmentedControl.selectedSegmentIndex forKey:kMyExercisesActiveFilterType];
}

- (void)loadData {
    
    [_orderedAllExercises removeAllObjects];
    [_exercisesByLocation removeAllObjects];
    [_exercisesByType removeAllObjects];

    if(!self.fetchedResultsController) {
        
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SavedExercise"];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"exerciseIdentifier" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.userContext sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController.delegate = self;
    }
    
    NSError * error = nil;
    BOOL success = [_fetchedResultsController performFetch:&error];
    
    if(!success) {
//        NSLog(@"MyExercises: fetch failed with error: %@", [error localizedDescription]);
    } else {
//        NSLog(@"MyExercises: fetch success with %d sections", [[self.fetchedResultsController sections] count]);
    }
    
    // Preemptively create filtered data sets, in case the user wishes to view them
    for(SavedExercise * exercise in self.fetchedResultsController.fetchedObjects) {
     
        Exercise * exerciseForSavedExercise = exercise.exercise;
        [self.orderedAllExercises addObject:exercise];
        
        ExerciseType * type = [[exerciseForSavedExercise.types allObjects] firstObject];
        
        // Determine location title, because the lookup method in Exercise model is apparently broken,
        // and I don't want regressions at this late stage, yes bad practice, whatever
        NSString * locationString = nil;
        if([[kExerciseLocationLookupHash allValues] indexOfObject:exerciseForSavedExercise.location] != NSNotFound) {
            locationString = [[kExerciseLocationLookupHash allKeysForObject:exerciseForSavedExercise.location] firstObject];
        }
        
        if(![[self.exercisesByType allKeys] containsObject:type.name]) {
            self.exercisesByType[type.name] = [[NSMutableArray alloc] init];
        }
        [_exercisesByType[type.name] addObject:exercise];
        
        if(![[self.exercisesByLocation allKeys] containsObject:locationString]) {
            self.exercisesByLocation[locationString] = [[NSMutableArray alloc] init];
        }
        [_exercisesByLocation[locationString] addObject:exercise];
        
    }
    
    // Sort
    [_orderedAllExercises sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((SavedExercise*)obj1).exercise.canonicalNameBasic compare:((SavedExercise*)obj2).exercise.canonicalNameBasic];
    }];
    [_exercisesByType sortKeys];
    [_exercisesByLocation sortKeys];
    
    for(NSString * key in [_exercisesByType allKeys]) {
        [_exercisesByType[key] sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [((SavedExercise*)obj1).exercise.canonicalNameBasic compare:((SavedExercise*)obj2).exercise.canonicalNameBasic];
        }];
    }
    for(NSString * key in [_exercisesByLocation allKeys]) {
        [_exercisesByLocation[key] sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [((SavedExercise*)obj1).exercise.canonicalNameBasic compare:((SavedExercise*)obj2).exercise.canonicalNameBasic];
        }];
    }
    
    if([self.fetchedResultsController.fetchedObjects count] == 0) {
        self.emptyView.hidden = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        // If user is editing and no items remain, toggle editing off
        if(self.tableView.editing) {
            [self toggleEdit:self.navigationItem.rightBarButtonItem];
        }
        
    } else {
        self.emptyView.hidden = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [self.tableView reloadData];
}

- (void)updateFilterSegmentHighlight {
    
    for (int i=0; i < [self.segmentedControl.subviews count]; i++) {
        if ([[self.segmentedControl.subviews objectAtIndex:i] isSelected] ) {
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                [[self.segmentedControl.subviews objectAtIndex:i] setTintColor:kLightTintColour];
            } else {
                [[self.segmentedControl.subviews objectAtIndex:i] setTintColor:RGBCOLOR(216, 116, 36)];
            }
        } else {
            [[self.segmentedControl.subviews objectAtIndex:i] setTintColor:[UIColor lightGrayColor]];
        }
    }
}

#pragma mark - Property Override Methods
- (void)setFilterType:(MyExercisesViewControllerFilterType)filterType {
    _filterType = filterType;
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(tableView == self.tableView) {
        
        if(self.filterType == MyExercisesViewControllerFilterTypeAll) {
            //        return [[self.fetchedResultsController sections] count];
            return 1;
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeLocation) {
            return [[self.exercisesByLocation allKeys] count];
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeType) {
            return [[self.exercisesByType allKeys] count];
        }
        
    } else if(tableView == self.searchController.searchResultsTableView) {
        
        if(self.filterType == MyExercisesViewControllerFilterTypeAll) {
            return 1;
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeLocation
                  || self.filterType == MyExercisesViewControllerFilterTypeType) {
            
            return [[self.sectionedSearchResults allKeys] count];
        }
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView == self.tableView) {
        
        if(self.filterType == MyExercisesViewControllerFilterTypeAll) {
            return [self.orderedAllExercises count];
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeLocation) {
            
            NSString * keyForSection = [self.exercisesByLocation allKeys][section];
            return [self.exercisesByLocation[keyForSection] count];
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeType) {
            
            NSString * keyForSection = [self.exercisesByType allKeys][section];
            return [self.exercisesByType[keyForSection] count];
        }
        
    } else if(tableView == self.searchController.searchResultsTableView) {
        
        if(self.filterType == MyExercisesViewControllerFilterTypeAll) {
            return [self.flatSearchResults count];
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeLocation
                  || self.filterType == MyExercisesViewControllerFilterTypeType) {
            
            NSString * keyForSection = [self.sectionedSearchResults allKeys][section];
            return [self.sectionedSearchResults[keyForSection] count];
        }   
    }

    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ExerciseCell * cell = [self.tableView dequeueReusableCellWithIdentifier:kExerciseCellReuseIdentifier forIndexPath:indexPath];
    
    SavedExercise * savedExercise = nil;
    
    if(tableView == self.tableView) {
     
        if(self.filterType == MyExercisesViewControllerFilterTypeAll) {
            savedExercise = self.orderedAllExercises[indexPath.row];
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeLocation) {
            
            NSString * keyForSection = [self.exercisesByLocation allKeys][indexPath.section];
            savedExercise = self.exercisesByLocation[keyForSection][indexPath.row];
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeType) {
            
            NSString * keyForSection = [self.exercisesByType allKeys][indexPath.section];
            savedExercise = self.exercisesByType[keyForSection][indexPath.row];
        }
        
    } else if(tableView == self.searchController.searchResultsTableView) {
        
        if(self.filterType == MyExercisesViewControllerFilterTypeAll) {
            savedExercise = self.flatSearchResults[indexPath.row];
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeLocation
                  || self.filterType == MyExercisesViewControllerFilterTypeType) {
            
            NSString * keyForSection = [self.sectionedSearchResults allKeys][indexPath.section];
            savedExercise = _sectionedSearchResults[keyForSection][indexPath.row];
        }
    }
    
    cell.selectedExercise = savedExercise.exercise;
    cell.starView = [[ExerciseStarView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-kStarViewWidth, 0, kStarViewWidth, kStarViewWidth) size:StarViewSizeSmall color:StarBackgroundColorOrange];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kProgramSectionHeaderHeight;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ProgramSectionHeaderView * headerView = [[ProgramSectionHeaderView alloc] init];
    headerView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return headerView;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(self.filterType == MyExercisesViewControllerFilterTypeAll) {
        return @"All Exercises";
        
    } else if(self.filterType == MyExercisesViewControllerFilterTypeLocation) {
        return [self.exercisesByLocation allKeys][section];
        
    } else if(self.filterType == MyExercisesViewControllerFilterTypeType) {
        return [self.exercisesByType allKeys][section];
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView != self.tableView) { // Catch search deletes, probably not possible, but just in case
        return;
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        SavedExercise * savedExercise = nil;
        
        [self.tableView beginUpdates];
        
        if(self.filterType == MyExercisesViewControllerFilterTypeAll) {
            savedExercise = self.orderedAllExercises[indexPath.row];
            [savedExercise.exercise toggleExerciseSaved];
            [_orderedAllExercises removeObject:savedExercise];
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeLocation) {
            
            NSString * keyForSection = [self.exercisesByLocation allKeys][indexPath.section];
            savedExercise = self.exercisesByLocation[keyForSection][indexPath.row];
            [savedExercise.exercise toggleExerciseSaved];
            
            [self.exercisesByLocation[keyForSection] removeObject:savedExercise];
            if([self.exercisesByLocation[keyForSection] count] == 0) {
                [self.exercisesByLocation removeObjectForKey:keyForSection];
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            }
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeType) {
            
            NSString * keyForSection = [self.exercisesByType allKeys][indexPath.section];
            savedExercise = self.exercisesByType[keyForSection][indexPath.row];
            [savedExercise.exercise toggleExerciseSaved];
            
            [self.exercisesByType[keyForSection] removeObject:savedExercise];
            if([self.exercisesByType[keyForSection] count] == 0) {
                [self.exercisesByType removeObjectForKey:keyForSection];
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        
        @try {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            // After animation is complete, get all other filtered sections into correct state that matches current filter
            [self performBlock:^{
                [self loadData];
            } afterDelay:0.5];
        }
        @catch (NSException *exception) {}
        
        [self.tableView endUpdates];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ExerciseDetailViewController *viewController = (ExerciseDetailViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                                                             bundle:NULL] instantiateViewControllerWithIdentifier:@"ExerciseDetailViewController"];
    
    SavedExercise * savedExercise = nil;
    
    if(tableView == self.tableView) {
        
        if(self.filterType == MyExercisesViewControllerFilterTypeAll) {
            savedExercise = self.orderedAllExercises[indexPath.row];
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeLocation) {
            
            NSString * keyForSection = [self.exercisesByLocation allKeys][indexPath.section];
            savedExercise = self.exercisesByLocation[keyForSection][indexPath.row];
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeType) {
            
            NSString * keyForSection = [self.exercisesByType allKeys][indexPath.section];
            savedExercise = self.exercisesByType[keyForSection][indexPath.row];
        }
        
    } else if(tableView == self.searchController.searchResultsTableView) {
        
        if(self.filterType == MyExercisesViewControllerFilterTypeAll) {
            savedExercise = self.flatSearchResults[indexPath.row];
            
        } else if(self.filterType == MyExercisesViewControllerFilterTypeLocation
                  || self.filterType == MyExercisesViewControllerFilterTypeType) {
            
            NSString * keyForSection = [self.sectionedSearchResults allKeys][indexPath.section];
            savedExercise = _sectionedSearchResults[keyForSection][indexPath.row];
        }
    }
    
    viewController.selectedExercise = savedExercise.exercise;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UISearchDisplayDelegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [_flatSearchResults removeAllObjects];
    [_sectionedSearchResults removeAllObjects];
    
    for(SavedExercise * savedExercise in _orderedAllExercises) {
        Exercise * exerciseForSavedExercise = savedExercise.exercise;
        
        if([[exerciseForSavedExercise.canonicalNameBasic lowercaseString] rangeOfString:[searchString lowercaseString]].location != NSNotFound || [[exerciseForSavedExercise.canonicalNameTechnical lowercaseString] rangeOfString:[searchString lowercaseString]].location != NSNotFound) {
            [_flatSearchResults addObject:savedExercise];
        }
    }
    
    [_flatSearchResults sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((SavedExercise*)obj1).exercise.canonicalNameBasic compare:((SavedExercise*)obj2).exercise.canonicalNameBasic];
    }];
    
    // Process into sections, if current filter is sectional
    if(self.filterType == MyExercisesViewControllerFilterTypeLocation) {
        
        for(SavedExercise * exercise in  _flatSearchResults) {
            
            Exercise * exerciseForSavedExercise = exercise.exercise;
            NSString * locationString = nil;
            if([[kExerciseLocationLookupHash allValues] indexOfObject:exerciseForSavedExercise.location] != NSNotFound) {
                locationString = [[kExerciseLocationLookupHash allKeysForObject:exerciseForSavedExercise.location] firstObject];
            }
            
            if(![[self.sectionedSearchResults allKeys] containsObject:locationString]) {
                self.sectionedSearchResults[locationString] = [[NSMutableArray alloc] init];
            }
            [_sectionedSearchResults[locationString] addObject:exercise];
        }
        
    } else if(self.filterType == MyExercisesViewControllerFilterTypeType) {
        
        for(SavedExercise * exercise in  _flatSearchResults) {
            
            Exercise * exerciseForSavedExercise = exercise.exercise;
            ExerciseType * type = [[exerciseForSavedExercise.types allObjects] firstObject];
            
            if(![[self.sectionedSearchResults allKeys] containsObject:type.name]) {
                self.sectionedSearchResults[type.name] = [[NSMutableArray alloc] init];
            }
            [_sectionedSearchResults[type.name] addObject:exercise];
        }
    }
    
    [_sectionedSearchResults sortKeys];
    for(NSString * key in [_sectionedSearchResults allKeys]) {
        [_sectionedSearchResults[key] sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [((SavedExercise*)obj1).exercise.canonicalNameBasic compare:((SavedExercise*)obj2).exercise.canonicalNameBasic];
        }];
    }
    
    return YES;
}

@end
