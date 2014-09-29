//
//  ExercisesViewController.m
//  StretchMate
//
//  Created by James Eunson on 20/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ExercisesViewController.h"
#import "AppDelegate.h"
#import "ExerciseImporter.h"
#import "ExercisesListingViewController.h"
#import "ProgressHUDHelper.h"
#import "ExerciseCell.h"
#import "ExerciseDetailViewController.h"
#import "ProgramsImporter.h"
#import "NSObject+PerformBlockAfterDelay.h"
#import "UIViewController+ToggleSidebar.h"
#import "ExerciseExporter.h"
#import "ProgramsExporter.h"
#import "ExerciseLocationButton.h"
#import "TutorialPageViewController.h"
#import "DisclaimerViewController.h"

typedef enum {
    AnatomyVisibleFront,
    AnatomyVisibleBack
} AnatomyVisible;

@interface ExercisesViewController ()
- (void)loadData;
- (void)didChangeFilter:(id)sender;
- (void)updateFilterSegmentHighlight;

- (void)importData;

@property (nonatomic, strong) UIView * anatomyScrollViewContainer;
@property (nonatomic, strong) UIImageView * frontAnatomyImageView;
@property (nonatomic, strong) UIImageView * backAnatomyImageView;
@property (nonatomic, assign) AnatomyVisible visibleAnatomy;
@property (nonatomic, strong) NSArray * frontIndicatorSet;
@property (nonatomic, strong) NSArray * backIndicatorSet;

@property (nonatomic, strong) UIView * innerScrollView;

@property (nonatomic, strong) UIButton * flipAnatomyButton;

@end

@implementation ExercisesViewController

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {
        
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        self.context = [delegate managedObjectContext];
        
        self.filterType = ExerciseFilterTypeLocation; // Init default
        self.visibleAnatomy = AnatomyVisibleFront;
        
        // Override default tab bar item
        UIImage *exercisesIcon = [UIImage imageNamed:@"exercises-icon"];
        UITabBarItem *exercisesTabBarItem = [[UITabBarItem alloc]
                                         initWithTitle:@"Exercises" image:exercisesIcon tag:1];
        [exercisesTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"exercises-icon-selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"exercises-icon"]];
        [self setTabBarItem:exercisesTabBarItem];
        
        self.locationExerciseCount = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[ExerciseCell class] forCellReuseIdentifier:@"exerciseCell"];
    [_tableView setScrollsToTop:YES];
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        _tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
        _tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    [self.view addSubview: _tableView];
    
    self.filterControl = [[UISegmentedControl alloc] initWithItems:@[ @"Map", @"Photos" ]];
    _filterControl.segmentedControlStyle = UISegmentedControlStyleBar;
    _filterControl.selectedSegmentIndex = 1;
    [_filterControl addTarget:self action:@selector(didChangeFilter:) forControlEvents:UIControlEventValueChanged];
    
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _filterControl.frame = CGRectMake(0, 0, 150.0f, 24.0f);
    } else {
        _filterControl.frame = CGRectMake(0, 0, 150.0f, 30.0f);
    }
    
    [self.navigationItem setTitleView:_filterControl];
    
    self.searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"Search Exercises";
    _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
//    _searchBar.barTintColor = [UIColor whiteColor];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
	[self.searchController setDelegate:self];
	[self.searchController setSearchResultsDataSource:self];
	[self.searchController setSearchResultsDelegate:self];
    
    self.searchController.searchResultsTableView.separatorInset = UIEdgeInsetsZero;
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        _searchBar.translucent = YES;
    }
    
    [self.view addSubview:_searchBar];
    
    self.anatomyScrollViewContainer = [[UIView alloc] init];
    
    self.anatomyScrollView = [[UIScrollView alloc] init];
    self.anatomyScrollView.delegate = self;
    _anatomyScrollView.scrollsToTop = NO;
    _anatomyScrollView.contentInset = UIEdgeInsetsMake(44.0f, 0, 0, 0);
    
    // Zooming is broken and problems with it cannot be solved in a timely manner
    self.anatomyScrollView.maximumZoomScale = 0.6f;
    self.anatomyScrollView.minimumZoomScale = 0.6f;
    
    self.innerScrollView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 700.0f, 700.0f)];
    self.frontAnatomyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"anatomy-body-front-new"]];
    [_innerScrollView addSubview:self.frontAnatomyImageView];
    
    self.backAnatomyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"anatomy-body-back-new"]];
    self.backAnatomyImageView.hidden = YES;
    [_innerScrollView addSubview:self.backAnatomyImageView];
    
    NSMutableArray * mutableFrontArray = [[NSMutableArray alloc] init];
    NSMutableArray * mutableBackArray = [[NSMutableArray alloc] init];
    
    int i = 0;
    for(NSString * key in [kExerciseLocationLookupHash allKeys]) {
        
        if([kIndicatorLocations.allKeys indexOfObject:key] != NSNotFound) {
            
            ExerciseLocationButton * locationButton = [[ExerciseLocationButton alloc] initWithFrame:CGRectMake([kIndicatorLocations[key][0] floatValue], [kIndicatorLocations[key][1] floatValue], 117, [ExerciseLocationButton heightForButtonWithTitle:key])];
            locationButton.key = key;
            [locationButton addTarget:self action:@selector(didTapAnatomyButton:) forControlEvents:UIControlEventTouchUpInside];
            
            if([kExerciseLocationsFront indexOfObject:kExerciseLocationLookupHash[key]] != NSNotFound) {
                [mutableFrontArray addObject:locationButton];
            } else {
                [mutableBackArray addObject:locationButton];
                locationButton.hidden = YES;
            }
            
            [_innerScrollView addSubview:locationButton];
        }
        
        i++;
    }
    
    self.frontIndicatorSet = mutableFrontArray;
    self.backIndicatorSet = mutableBackArray;
    
    [self.anatomyScrollView addSubview:_innerScrollView];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [self.anatomyScrollView setContentOffset: CGPointMake(56.0f, 38.0f) animated: NO];
    } else {
        [self.anatomyScrollView setContentOffset: CGPointMake(56.0f, -82.0f) animated: NO];
    }
    
    [self.anatomyScrollViewContainer addSubview:self.anatomyScrollView];
    
    // Create anatomy background
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        UIImageView * backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-bg"]];
        backgroundView.frame = CGRectMake(0, 0, self.anatomyScrollViewContainer.frame.size.width, self.anatomyScrollViewContainer.frame.size.height);
        [self.anatomyScrollViewContainer addSubview:backgroundView];
        [self.anatomyScrollViewContainer sendSubviewToBack:backgroundView];
        
    } else {
        self.anatomyScrollViewContainer.backgroundColor = RGBCOLOR(238, 238, 238);
    }
    
    [self.view addSubview:self.anatomyScrollViewContainer];
    
    self.flipAnatomyButton = [[UIButton alloc] init];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [_flipAnatomyButton setImage:[UIImage imageNamed:@"anatomy-flip-button"] forState:UIControlStateNormal];
    } else {
        [_flipAnatomyButton setImage:[UIImage imageNamed:@"anatomy-flip-button-ios7"] forState:UIControlStateNormal];
    }
    _flipAnatomyButton.layer.borderColor = [RGBCOLOR(180, 180, 180) CGColor];
    _flipAnatomyButton.layer.borderWidth = 1.0f;
    _flipAnatomyButton.layer.cornerRadius = 4.0f;
    _flipAnatomyButton.backgroundColor = [UIColor whiteColor];
    
    _flipAnatomyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_flipAnatomyButton addTarget:self action:@selector(didTapFlipAnatomyButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.anatomyScrollViewContainer addSubview:_flipAnatomyButton];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_anatomyScrollViewContainer, _tableView, _searchBar, _anatomyScrollView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_searchBar]|" options:0 metrics:nil views:bindings]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_searchBar]" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:bindings]];
    
    [_toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_filterControl]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_filterControl)]];
    [_toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_filterControl]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_filterControl)]];
    
    [self.anatomyScrollViewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-54-[_flipAnatomyButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_flipAnatomyButton)]];
    [self.anatomyScrollViewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_flipAnatomyButton]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_flipAnatomyButton)]];

    [self.view bringSubviewToFront:_searchBar];
    [self.view bringSubviewToFront:_toolbar];
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSLog(@"viewDidLoad");

    self.navigationController.navigationBar.translucent = NO;
    
    self.toolbar.tintColor = kTintColour;
    
    self.anatomyScrollView.zoomScale = 0.6;
    
    [self.filterControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [self.filterControl addTarget:self action:@selector(didChangeFilter:) forControlEvents:UIControlEventValueChanged];
    
    [self.filterControl setTitle:kExerciseFilterTypes[0] forSegmentAtIndex:0];
    [self.filterControl setTitle:kExerciseFilterTypes[1] forSegmentAtIndex:1];
    
    [self.filterControl setSelectedSegmentIndex:0];
    
    // For no apparent reason, this actually works
    [self performBlock:^{
        [self updateFilterSegmentHighlight];
    } afterDelay:0.1];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        
        UIBarButtonItem * drawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toggle-sidebar-icon"] style:UIBarButtonItemStyleBordered target:self action:@selector(didToggleSidebar:)];
        self.navigationItem.leftBarButtonItem = drawerButton;
        
    } else {
        
        self.toolbar.translucent = NO;
        
        UIBarButtonItem * drawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toggle-sidebar-icon-ios7"] style:UIBarButtonItemStyleBordered target:self action:@selector(didToggleSidebar:)];
        self.navigationItem.leftBarButtonItem = drawerButton;
    }
    
    [self loadData];
    
    if(![[AppConfig sharedConfig] tutorialShown]) {
    
//        TutorialPageViewController * controller = [[TutorialPageViewController alloc] init];
//        [self presentViewController:controller animated:YES completion:^{
//            [[AppConfig sharedConfig] setBool:YES forKey:kTutorialShown];
//        }];
        
        NSString * filePath = [[NSBundle mainBundle] pathForResource:@"Disclaimer" ofType:@"html"];
        DisclaimerViewController * controller = [[DisclaimerViewController alloc] init];
        controller.url = [NSURL fileURLWithPath:filePath];
        
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navController animated:YES completion:nil];
        
        [[AppConfig sharedConfig] setBool:YES forKey:kTutorialShown];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.anatomyScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.anatomyScrollViewContainer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.frontAnatomyImageView.frame = CGRectMake(100, 100, self.frontAnatomyImageView.frame.size.width, self.frontAnatomyImageView.frame.size.height);
    self.backAnatomyImageView.frame = CGRectMake(100, 100, self.backAnatomyImageView.frame.size.width, self.backAnatomyImageView.frame.size.height);

    CGFloat anatomyScrollViewContentSizeWidth = self.view.frame.size.width + 400.0f;
    CGFloat horizontalContentOffset = 200.0f;
    
    self.anatomyScrollView.contentSize = CGSizeMake(anatomyScrollViewContentSizeWidth, 700.0f);
    
    CGFloat innerScrollViewHorizontalPosition = (anatomyScrollViewContentSizeWidth / 2) - (_innerScrollView.frame.size.width / 2);
    self.innerScrollView.frame = CGRectMake(innerScrollViewHorizontalPosition, 66.0f, _innerScrollView.frame.size.width, _innerScrollView.frame.size.height);
    _anatomyScrollView.contentOffset = CGPointMake(horizontalContentOffset, 44.0f);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {
    
    if(self.filterType == ExerciseFilterTypeLocation) {
        return 1;
    } else {
        return [[self.typesFetchedResultsController sections] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.searchFetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else {
        if(self.filterType == ExerciseFilterTypeLocation) {
            return [[Exercise sortedExerciseLocations] count];
        } else {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.typesFetchedResultsController sections] objectAtIndex:section];
            return [sectionInfo numberOfObjects];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"exerciseCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];            
    
    // Cell is describing a single exercise, as per listing controller
    if(tableView == self.searchDisplayController.searchResultsTableView) {
        
        Exercise * exercise = (Exercise*)[self.searchFetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text  = exercise.nameBasic;
        cell.detailTextLabel.text = exercise.typesString;
        cell.imageView.image = [exercise getThumbnailImage];
        
    } else { // Cell is describing a type or location, including total item information
        
        if(self.filterType == ExerciseFilterTypeLocation) {
            
            NSString * locationString = [[Exercise sortedExerciseLocations] objectAtIndex:indexPath.row];
            cell.textLabel.text = locationString;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d exercises", [self.locationExerciseCount[locationString] intValue]];
            
        } else { // ExerciseFilterTypeExerciseType
            
            ExerciseType * type = (ExerciseType*)[self.typesFetchedResultsController objectAtIndexPath:indexPath];
            cell.textLabel.text = type.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d exercises", type.exercises.count];
            
            Exercise * firstExercise = [[type.exercises allObjects] firstObject];
            cell.imageView.image = [firstExercise getThumbnailImage];
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if(tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"ExerciseDetailSegue" sender:nil];
        
    } else {
        
        [self performSegueWithIdentifier:@"ExerciseListingSegue" sender:nil];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Private Methods
- (void)loadData {
    
    if(!self.typesFetchedResultsController) {
        
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ExerciseType"];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        self.typesFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
        self.typesFetchedResultsController.delegate = self;
    }
    
//    else {
//        NSEntityDescription * entityDescription = [NSEntityDescription entityForName:@"ExerciseType" inManagedObjectContext:self.context];
//        [_fetchedResultsController.fetchRequest setPredicate:nil];
//        [_fetchedResultsController.fetchRequest setEntity:entityDescription];
//        [_fetchedResultsController.fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]];
//    }
    
    NSError * error = nil;
    BOOL success = [_typesFetchedResultsController performFetch:&error];
    
    if(!success) {
//        NSLog(@"Exercises: fetch failed");
    } else {
//        NSLog(@"Exercises: fetch success with %d sections", [[self.typesFetchedResultsController sections] count]);
    }
    
    // Retrieve exercise aggregate count by location
    NSFetchRequest * locationFetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
    NSArray * locations = [Exercise sortedExerciseLocations];
    
    for(NSString * locationString in locations) {
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"location == %@", [Exercise getTypeForLocationString: locationString]];
        locationFetchRequest.predicate = predicate;
        NSArray * results = [self.context executeFetchRequest:locationFetchRequest error:&error];
        
        self.locationExerciseCount[locationString] = @([results count]);
    }
    
    if(!self.searchFetchedResultsController) {
        
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        self.searchFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
        self.searchFetchedResultsController.delegate = self;
    }
}

- (void)importData {
//    ExerciseImporter * importer = [[ExerciseImporter alloc] init];
//    [importer startImportWithCompletion:^(BOOL success) {
//        NSLog(@"ExerciseImporter: Completion called");
//
//        ProgramsImporter * programsImporter = [[ProgramsImporter alloc] init];
//        [programsImporter startImportWithCompletion:^(BOOL success) {
//            NSLog(@"ProgramsImporter: Completion called");
//        }];
//    }];

//    ExerciseExporter * exporter = [[ExerciseExporter alloc] init];
//    [exporter startExportWithCompletion:^(BOOL success) {
//        NSLog(@"startExport");
//
//        ProgramsExporter * programsExporter = [[ProgramsExporter alloc] init];
//        [programsExporter startExportWithCompletion:^(BOOL success) {
//            NSLog(@"finished programs export");
//        }];
//    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"ExerciseListingSegue"]) {
        
        ExercisesListingViewController *detailViewController = [segue destinationViewController];        
        
        if(sender != nil) {
            
            UIButton * senderButton = (UIButton*)sender;
            NSArray * keys = [kExerciseLocationLookupHash allKeysForObject:@(senderButton.tag)];
            NSString * key = [keys firstObject];
            
            ExerciseLocation location = [[Exercise getTypeForLocationString:key] intValue];
            detailViewController.currentLocation = location;
            
        } else {
            
            NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
            
            if(self.filterType == ExerciseFilterTypeLocation) {
                
                NSString * locationString = [[Exercise sortedExerciseLocations] objectAtIndex:selectedRowIndex.row];
                ExerciseLocation location = [[Exercise getTypeForLocationString:locationString] intValue];
                detailViewController.currentLocation = location;
                
            } else {
                
                ExerciseType * type = (ExerciseType*)[self.typesFetchedResultsController objectAtIndexPath:selectedRowIndex];
                detailViewController.currentType = type;
            }   
        }
        
    } else if([[segue identifier] isEqualToString:@"LoginSegue"]) {
        
        UINavigationController * modalNavController = [segue destinationViewController];
        LoginViewController *loginController = (LoginViewController*)modalNavController.topViewController;
        loginController.delegate = self;
        
    } else if([[segue identifier] isEqualToString:@"ExerciseDetailSegue"]) {
        
        NSIndexPath *selectedRowIndex = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        ExerciseDetailViewController *detailViewController = [segue destinationViewController];
        
        Exercise * exercise = (Exercise*)[self.searchFetchedResultsController objectAtIndexPath:selectedRowIndex];
        detailViewController.selectedExercise = exercise;
    }
}

#pragma mark - UISearchDiplayDelegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    NSEntityDescription * entityDescription = [NSEntityDescription entityForName:@"Exercise" inManagedObjectContext:self.context];
    NSPredicate * searchPredicate = [NSPredicate predicateWithFormat:@"nameTechnical CONTAINS[cd] %@ OR nameBasic CONTAINS[cd] %@", self.searchDisplayController.searchBar.text, self.searchDisplayController.searchBar.text];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nameBasic" ascending:YES];
    
    [_searchFetchedResultsController.fetchRequest setSortDescriptors:@[sortDescriptor]];
    [_searchFetchedResultsController.fetchRequest setPredicate:searchPredicate];
    [_searchFetchedResultsController.fetchRequest setEntity:entityDescription];
    
    NSError * error = nil;
    BOOL success = [_searchFetchedResultsController performFetch:&error];
    
    if(!success) {
//        NSLog(@"Exercises: fetch failed");
    } else {
//        NSLog(@"Exercises: fetch success with %d items", [[[_searchFetchedResultsController sections] firstObject] numberOfObjects]);
    }
    
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
//    NSLog(@"willHideSearchResultsTableView");
    [self loadData];
}

#pragma mark -
- (void)didChangeFilter:(id)sender {
    
    UISegmentedControl * control = (UISegmentedControl*)sender;
    
    self.filterType = control.selectedSegmentIndex;
    
    if(self.filterType == 0) {
        self.anatomyScrollViewContainer.hidden = NO;
        if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
            self.toolbar.translucent = NO;
        }
    } else {
        self.anatomyScrollViewContainer.hidden = YES;
        if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
            self.toolbar.translucent = YES;
        }
    }
    
    [self updateFilterSegmentHighlight];
    [self.tableView reloadData];
}

- (void)updateFilterSegmentHighlight {
    
    // Modify selected segment color
    for (int i=0; i < [self.filterControl.subviews count]; i++) {
        if ([[self.filterControl.subviews objectAtIndex:i] isSelected] ) {
            
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                [[self.filterControl.subviews objectAtIndex:i] setTintColor:kLightTintColour];
            } else {
                [[self.filterControl.subviews objectAtIndex:i] setTintColor:RGBCOLOR(216, 116, 36)];
            }
            
        } else {
            [[self.filterControl.subviews objectAtIndex:i] setTintColor:[UIColor lightGrayColor]];
        }
    }
}

- (void)didTapAnatomyButton:(id)sender {
//    NSLog(@"didTapAnatomyButton");
    
    UIButton * senderButton = (UIButton*)sender;
    [self performSegueWithIdentifier:@"ExerciseListingSegue" sender:senderButton];
}

- (void)didDoubleTapScrollView:(id)sender {
    
    if(self.anatomyScrollView.zoomScale == 1.5f) {
        [self.anatomyScrollView setZoomScale:1.0f animated:YES];        
    } else if(self.anatomyScrollView.zoomScale < 1.0f) {
        [self.anatomyScrollView setZoomScale:1.0f animated:YES];
    } else {
        [self.anatomyScrollView setZoomScale:1.5f animated:YES];
    }
}

- (void)didTapFlipAnatomyButton:(id)sender {
//    NSLog(@"didTapFlipAnatomyButton");
    
    if(self.visibleAnatomy == AnatomyVisibleFront) { // Front -> Back
        
        self.visibleAnatomy = AnatomyVisibleBack;
        self.backAnatomyImageView.alpha = 0.f;
        self.backAnatomyImageView.hidden = NO;
        
        for(UIView * locationIndicator in self.backIndicatorSet) {
            locationIndicator.alpha = 0.0f;            
            locationIndicator.hidden = NO;
        }
        
        [UIView animateWithDuration:0.5f animations:^{
            
            self.frontAnatomyImageView.alpha = 0.0f;
            self.backAnatomyImageView.alpha = 1.0f;
            
            for(UIView * locationIndicator in self.frontIndicatorSet) {
                locationIndicator.alpha = 0.0f;
            }
            
            for(UIView * locationIndicator in self.backIndicatorSet) {
                locationIndicator.alpha = 1.0f;
            }
            
        } completion:^(BOOL finished) {
            self.frontAnatomyImageView.hidden = YES;
            self.backAnatomyImageView.hidden = NO;
            
            for(UIView * locationIndicator in self.frontIndicatorSet) {
                locationIndicator.hidden = YES;
            }
        }];
        
    } else { // Back -> Front
        
        self.visibleAnatomy = AnatomyVisibleFront;
        self.frontAnatomyImageView.alpha = 0.f;
        self.frontAnatomyImageView.hidden = NO;
        
        for(UIView * locationIndicator in self.frontIndicatorSet) {
            locationIndicator.alpha = 0.0f;
            locationIndicator.hidden = NO;
        }
        
        [UIView animateWithDuration:0.5f animations:^{
            
            self.frontAnatomyImageView.alpha = 1.0f;
            self.backAnatomyImageView.alpha = 0.0f;
            
            for(UIView * locationIndicator in self.backIndicatorSet) {
                locationIndicator.alpha = 0.0f;
            }
            
            for(UIView * locationIndicator in self.frontIndicatorSet) {
                locationIndicator.alpha = 1.0f;
            }
            
        } completion:^(BOOL finished) {
            self.frontAnatomyImageView.hidden = NO;
            self.backAnatomyImageView.hidden = YES;
            
            for(UIView * locationIndicator in self.backIndicatorSet) {
                locationIndicator.hidden = YES;
            }
        }];
    }
}

#pragma mark - LoginControllerDelegate
- (void)loginViewControllerDidLogin:(LoginViewController*)controller {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [ProgressHUDHelper showConfirmationHUDWithImage:[UIImage imageNamed:@"tick"] withLabelText:@"Logged In" withDetailsLabelText:@"You are now logged in"];
}

#pragma mark - UIScrollViewDelegate Methods
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return scrollView.subviews[0];
}

@end
