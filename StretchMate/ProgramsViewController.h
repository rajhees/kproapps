//
//  ProgramsViewController.h
//  StretchMate
//
//  Created by James Eunson on 13/02/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgramsViewController : UIViewController <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSManagedObjectContext * context;

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UISearchDisplayController * searchController;

@property (nonatomic, strong) NSArray * programs;
@property (nonatomic, strong) NSMutableArray * filteredPrograms;

@property (nonatomic, strong) UISearchBar * searchBar;

@end
