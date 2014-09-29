//
//  MyExercisesViewController.h
//  Exersite
//
//  Created by James Eunson on 1/12/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyExercisesEmptyView.h"

typedef enum {
    MyExercisesViewControllerFilterTypeAll,
    MyExercisesViewControllerFilterTypeType,
    MyExercisesViewControllerFilterTypeLocation
} MyExercisesViewControllerFilterType;

@interface MyExercisesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UIToolbar * toolbar;
@property (nonatomic, strong) UISegmentedControl * segmentedControl;

@property (nonatomic, strong) UISearchBar * searchBar;
@property (nonatomic, strong) UISearchDisplayController * searchController;
@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;

@property (nonatomic, assign) MyExercisesViewControllerFilterType filterType;

@property (nonatomic, strong) MyExercisesEmptyView * emptyView;

@end
