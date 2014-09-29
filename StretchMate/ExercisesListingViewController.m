//
//  ExercisesListingViewController.m
//  StretchMate
//
//  Created by James Eunson on 23/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExercisesListingViewController.h"
#import "AppDelegate.h"
#import "SavedExercise.h"
#import "ExerciseDetailViewController.h"
#import "ExerciseStarView.h"
#import "ExerciseCell.h"
#import "NSArray+FirstObject.h"
#import "ProgramSectionHeaderView.h"
#import "ExercisesListingHeaderView.h"
#import "ProgramDescriptionCell.h"

#define kExerciseDescriptionCell @"exerciseDescriptionCell"
#define kProprioceptionDescriptionString @"Receptors in muscles and tendons provide information regarding position of limbs in space and what is required for coordinated movement of these limbs. Proprioceptive exercises help improve this co-ordination especially important after injury eg, ankle sprain because these receptors can be damaged."

@interface ExercisesListingViewController ()
- (void)loadData;
- (void)loadUserData;

@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) NSManagedObjectContext * userContext;

@property (nonatomic, strong) ExercisesListingHeaderView * headerView;

@end

@implementation ExercisesListingViewController

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.context = [delegate managedObjectContext];
        self.userContext = [delegate userManagedObjectContext];
        
        self.exercises = [[NSDictionary alloc] init];
        self.difficultiesForExercises = [[NSArray alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    [self.tableView registerClass:[ProgramDescriptionCell class] forCellReuseIdentifier:kExerciseDescriptionCell];
    
    NSString * titleString = nil;
    if(self.currentType) {
        titleString = self.currentType.name;
    } else {
        titleString = [[Exercise sortedExerciseLocations] objectAtIndex:self.currentLocation];
    }
    
    self.headerView = [[ExercisesListingHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150 + 44.0f)];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _headerView.titleLabel.text = titleString;
    _headerView.searchBar.delegate = self;
    [self.tableView setTableHeaderView:_headerView];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:_headerView.searchBar contentsController:self];
	[self.searchController setDelegate:self];
	[self.searchController setSearchResultsDataSource:self];
	[self.searchController setSearchResultsDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = YES;
    
    if(self.currentType) {
        self.title = self.currentType.name;
        self.searchBar.placeholder = [NSString stringWithFormat:@"Search in %@", self.title];
    } else {
        self.title = [[Exercise sortedExerciseLocations] objectAtIndex:self.currentLocation];
        self.searchBar.placeholder = [NSString stringWithFormat:@"Search in %@", self.title];
    }
    [self loadData];
    
    _headerView.exercises = self.allExercises;    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    self.tableView.contentOffset = CGPointMake(0, 44.0f);
    [self loadUserData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredDifficulties count];
        
    } else {
        
        if(self.currentType && [[self.currentType.name lowercaseString] isEqualToString:@"proprioception"]) {
            return [self.difficultiesForExercises count] + 1;
        } else {
            return [self.difficultiesForExercises count];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        
        NSString * key = self.filteredDifficulties[section];
        return [self.filteredExercises[key] count];
        
    } else {
        
        if(self.currentType && [[self.currentType.name lowercaseString] isEqualToString:@"proprioception"]) {
            if(section == 0) {
                return 1;
                
            } else {
                
                NSString * key = self.difficultiesForExercises[section-1];
                return [self.exercises[key] count];
            }
            
        } else {
            NSString * key = self.difficultiesForExercises[section];
            return [self.exercises[key] count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"cellForRowAtIndexPath: section: %d, row: %d", indexPath.section, indexPath.row);
    
    NSIndexPath * adjustedIndexPath = nil;
    if(self.currentType && [[self.currentType.name lowercaseString] isEqualToString:@"proprioception"]) {
        if(indexPath.section == 0) {
            
            ProgramDescriptionCell * cell = [self.tableView dequeueReusableCellWithIdentifier:kExerciseDescriptionCell forIndexPath:indexPath];
            cell.textLabel.text = kProprioceptionDescriptionString;
            [cell setNeedsLayout];
            
            return cell;
            
        } else { // Adjust indexPath so that description is in the first cell, then fallthrough
            adjustedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:(indexPath.section - 1)];
        }
    }
    
    static NSString *CellIdentifier = @"exerciseListingCell";
    ExerciseCell *cell = (ExerciseCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray * exercisesForSection = nil;
    
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        
        NSString * key = self.filteredDifficulties[indexPath.section];
        exercisesForSection = self.filteredExercises[key];
        
    } else {
        
        if(self.currentType && [[self.currentType.name lowercaseString] isEqualToString:@"proprioception"]) {
            NSString * key = self.difficultiesForExercises[adjustedIndexPath.section];
            exercisesForSection = self.exercises[key];
            
        } else {
            
            NSString * key = self.difficultiesForExercises[indexPath.section];
            exercisesForSection = self.exercises[key];
        }
    }
    
    Exercise * exercise = exercisesForSection[indexPath.row];
    
    // If exercise is overlap, replace with actual exercise
    if(![exercise isCanonical]) {
        exercise = exercise.canonicalExercise;
    }
    
    cell.textLabel.text  = exercise.nameBasic;
    cell.detailTextLabel.text = exercise.typesString;
    
    if([self.savedExercises indexOfObject: exercise.identifier] != NSNotFound) {
        cell.starView = [[ExerciseStarView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-kStarViewWidth, 0, kStarViewWidth, kStarViewWidth) size:StarViewSizeSmall color:StarBackgroundColorOrange];
    } else {
        if(cell.starView) [cell.starView removeFromSuperview];
    }
    
    cell.imageView.image = [exercise getThumbnailImage];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kProgramSectionHeaderHeight;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ProgramSectionHeaderView * headerView = [[ProgramSectionHeaderView alloc] init];
    headerView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.currentType && [[self.currentType.name lowercaseString] isEqualToString:@"proprioception"]
       && indexPath.section == 0 && tableView == self.tableView) {
        return [ProgramDescriptionCell heightWithString:kProprioceptionDescriptionString];
        
    } else {
        return 55.0f;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        return self.filteredDifficulties[section];
    } else {
        
        if(self.currentType && [[self.currentType.name lowercaseString] isEqualToString:@"proprioception"]) {
            if(section == 0) {
                return @"About Proprioception";
            } else {
                return self.difficultiesForExercises[section-1];
            }
        } else {
            return self.difficultiesForExercises[section];
        }
    }
}

#pragma mark - UISearchDisplayDelegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    NSPredicate * searchPredicate = [NSPredicate predicateWithFormat:@"canonicalNameTechnical CONTAINS[cd] %@ OR canonicalNameBasic CONTAINS[cd] %@", self.searchDisplayController.searchBar.text, self.searchDisplayController.searchBar.text];
    NSPredicate * sectionPredicate = nil;
    
    if(self.currentType) {
        sectionPredicate = [NSPredicate predicateWithFormat:@"ANY types.name == %@", self.currentType.name];
    } else {
        sectionPredicate = [NSPredicate predicateWithFormat:@"location == %@", @(self.currentLocation)];
    }
    
    NSPredicate * compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[searchPredicate, sectionPredicate]];
    
    NSArray * filteredExercisesArray = [self.allExercises filteredArrayUsingPredicate:compoundPredicate];
    
    self.filteredExercises = [Exercise categorizeExercisesByDifficulty:filteredExercisesArray];
    self.filteredDifficulties = [Exercise generateDifficultiesForCategorizedExercises:self.filteredExercises];
    
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
//    NSLog(@"willHideSearchResultsTableView");
    [self loadData];
}

// Fixes the absolutely messed up behaviour of UISearchDisplayController in relation to actually
// ripping your UISearchBar from its original context and then attempting to put it back in place, which it does extremely poorly
// by adding it as a subview to the UITableView. Instead, we nuke the version created by
// UISearchDisplayController and reinstate our own

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    
    for(UIView * subview in [self.tableView subviews]) {
        if([subview isKindOfClass:[UISearchBar class]]) {
            [subview removeFromSuperview];
        }
    }
    
    [_headerView reinstateSearchBar];
}

#pragma mark - Private Methods
- (void)loadData {
    
//    NSLog(@"ExercisesListingViewController: loadData");
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSPredicate * predicate = nil;
    
    if(self.currentType) {
        predicate = [NSPredicate predicateWithFormat:@"ANY types.name == %@", self.currentType.name];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"location == %@", @(self.currentLocation)];
    }
    
    // Calls of this function subsequent to the first imply a search has taken place, therefore the predicate has to be reset
    if(!self.fetchedResultsController) {
        
        [fetchRequest setPredicate:predicate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nameBasic" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:@"level" cacheName:nil];
        self.fetchedResultsController.delegate = self;
        
    } else {
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    }
    
    NSError * error = nil;
    BOOL success = [_fetchedResultsController performFetch:&error];
    
    NSArray * fetchedAllExercises = self.fetchedResultsController.fetchedObjects;
    fetchedAllExercises = [Exercise updateOverlappedWithExerciseInExerciseArray:fetchedAllExercises]; // Post overlap fill-in and sort
    
    self.allExercises = fetchedAllExercises;
    
    // Group exercises into difficulties
    NSDictionary * exercisesMutable = [Exercise categorizeExercisesByDifficulty:fetchedAllExercises];
    self.exercises = exercisesMutable;
    
    // Store ordered difficulties for current set
    self.difficultiesForExercises = [Exercise generateDifficultiesForCategorizedExercises:exercisesMutable];
    
    if(!success) {
//        NSLog(@"Exercises Listing: fetch failed with error: %@", [error localizedDescription]);
    } else {
//        NSLog(@"Exercises Listing: fetch success with %d sections", [[self.fetchedResultsController sections] count]);
    }
}

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
    
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"ExerciseDetailSegue"]) {
        
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        NSArray * exercisesForSection = nil;
        
        if(!selectedRowIndex) { // UISearchDisplayController active
            
            selectedRowIndex = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            
            NSString * key = self.filteredDifficulties[selectedRowIndex.section];
            exercisesForSection = self.filteredExercises[key];
            
        } else {
            
            if(self.currentType && [[self.currentType.name lowercaseString] isEqualToString:@"proprioception"]) {
                selectedRowIndex = [NSIndexPath indexPathForRow:selectedRowIndex.row inSection:(selectedRowIndex.section - 1)];
            }
            
            NSString * key = self.difficultiesForExercises[selectedRowIndex.section];
            exercisesForSection = self.exercises[key];
        }
        
        Exercise * exercise = exercisesForSection[selectedRowIndex.row];
        
        if(![exercise isCanonical]) {
            exercise = exercise.canonicalExercise;
        }
        
        ExerciseDetailViewController *detailViewController = [segue destinationViewController];
        
        detailViewController.selectedExercise = exercise;
    }
}

@end
