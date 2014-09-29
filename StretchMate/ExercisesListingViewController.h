//
//  ExercisesListingViewController.h
//  StretchMate
//
//  Created by James Eunson on 23/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseType.h"
#import "Exercise.h"

@interface ExercisesListingViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;

@property (nonatomic, strong) ExerciseType * currentType;
@property (nonatomic, assign) ExerciseLocation currentLocation;

@property (nonatomic, strong) NSArray * savedExercises;

// Non-search data properties
@property (nonatomic, strong) NSDictionary * exercises;
@property (nonatomic, strong) NSArray * difficultiesForExercises;

// Enables search
@property (nonatomic, strong) NSArray * allExercises;
@property (nonatomic, strong) NSDictionary * filteredExercises;
@property (nonatomic, strong) NSArray * filteredDifficulties;

@property (nonatomic, strong) UISearchBar * searchBar;
@property (nonatomic, strong) UISearchDisplayController * searchController;

@end
