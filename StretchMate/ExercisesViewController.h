//
//  ExercisesViewController.h
//  StretchMate
//
//  Created by James Eunson on 20/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exercise.h"
#import "LoginViewController.h"

@interface ExercisesViewController : UIViewController <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, LoginControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) ExerciseFilterType filterType;

@property (nonatomic, strong) NSFetchedResultsController * searchFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController * typesFetchedResultsController;

@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) NSMutableDictionary * locationExerciseCount;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UISegmentedControl * filterControl;
@property (nonatomic, strong) UISearchDisplayController * searchController;
@property (nonatomic, strong) UISearchBar * searchBar;
@property (nonatomic, strong) UIToolbar * toolbar;

@property (nonatomic, strong) UIScrollView * anatomyScrollView;

@end
