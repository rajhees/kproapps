//
//  ShopViewController.m
//  StretchMate
//
//  Created by James Eunson on 3/12/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import "ShopViewController.h"
#import "ShopItemCell.h"
#import "ShopFlowLayout.h"
#import "ShopSectionHeaderView.h"
#import "ShopDetailViewController.h"
#import "ShopItemImporter.h"
#import "AppDelegate.h"
#import "UIViewController+ToggleSidebar.h"
#import "ProgramSectionHeaderView.h"
#import "ExersiteHTTPClient.h"
#import "ProgressHUDHelper.h"
#import "UIImageView+AFNetworking.h"
#import "ShopCategoryToolbarButton.h"
#import "ExersiteSession.h"

#define kCellReuseIdentifier @"ShopIconIdentifier"
#define kHeaderReuseIdentifier @"ShopSectionHeaderView"

@interface ShopViewController ()
- (void)loadShopData;
- (void)loadCategoryData;

- (void)refreshShop:(id)sender;

//- (void)_createCategoryCollectionViewConstraints;
- (void)_layoutCollectionViews;
- (void)_checkSelectedCategoryLoadStatusForPage:(NSInteger)pageNumber;

@property (nonatomic, strong) NSMutableDictionary * categoryItems;

@property (nonatomic, assign) BOOL categoryCollectionViewLayoutDone;
@property (nonatomic, assign) NSInteger currentPageNumber;

@end

@implementation ShopViewController

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {
        
        // Override default tab bar item
        UIImage *notificationsIcon = [UIImage imageNamed:@"shop-icon"];
        UITabBarItem *notificationsTabBarItem = [[UITabBarItem alloc]
                                                 initWithTitle:@"Shop" image:notificationsIcon tag:0];
        [notificationsTabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"shop-icon-selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"shop-icon"]];
        [self setTabBarItem:notificationsTabBarItem];
        
        self.categoryCollectionViewLayoutDone = NO;
        self.categoryItems = [[NSMutableDictionary alloc] init];
        self.currentPageNumber = 0;
        
        self.mode = ShopDetailModeNormal;
        
//        ShopItemImporter * importer = [[ShopItemImporter alloc] init];
//        [importer startImportWithCompletion:^(BOOL success) {
//            NSLog(@"import complete");
//        }];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        UIImageView * backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-bg"]];
        [self.view addSubview:backgroundView];
        [self.view sendSubviewToBack:backgroundView];
    } else {
        self.view.backgroundColor = RGBCOLOR(238, 238, 238);
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
    
    if(self.mode == ShopViewControllerModeNormal) {
     
        self.contentScrollView = [[UIScrollView alloc] init];
        
        _contentScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        _contentScrollView.pagingEnabled = YES;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.delegate = self;
        
        [self.view addSubview:_contentScrollView];
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        _collectionView.contentInset = UIEdgeInsetsMake(44, 0, 88, 0); // Compensate for both toolbars, top and bottom
        
        [self.collectionView registerClass:[ShopItemCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
        [self.collectionView registerClass:[ProgramSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier];
        
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
        
        // Has to be fixed frame, don't bother with constraints here, likewise base collectionview and category collection views
        // The proportions of these are updated in viewDidLayoutSubviews, this restriction is imposed by Apple on uiscrollview children
        
        self.headerView = [[ShopShippingInformationHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 92.0f)];
        _headerView.delegate = self;
        [_collectionView addSubview:_headerView];
     
        [self.contentScrollView addSubview:_collectionView];
        
        self.toolbar = [[ShopCartOrdersToolbar alloc] init];
        _toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        _toolbar.cartOrdersDelegate = self;
        [self.view addSubview:_toolbar];
     
        self.categoryToolbar = [[ShopCategoryToolbar alloc] init];
        _categoryToolbar.translatesAutoresizingMaskIntoConstraints = NO;
        _categoryToolbar.categoryToolbarDelegate = self;
        
        [self.view addSubview:_categoryToolbar];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_contentScrollView, _toolbar, _categoryToolbar, _headerView);
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|" options:0 metrics:nil views:bindings]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_categoryToolbar]|" options:0 metrics:nil views:bindings]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentScrollView]|" options:0 metrics:nil views:bindings]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_toolbar]|" options:0 metrics:nil views:bindings]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_categoryToolbar(44)]" options:0 metrics:nil views:bindings]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentScrollView]|" options:0 metrics:nil views:bindings]];
        
        [self.view bringSubviewToFront:_toolbar];
        
    } else {
        
        self.selectedCategoryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        
        _selectedCategoryCollectionView.delegate = self;
        _selectedCategoryCollectionView.dataSource = self;
        _selectedCategoryCollectionView.backgroundColor = [UIColor clearColor];
        _selectedCategoryCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_selectedCategoryCollectionView registerClass:[ShopItemCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
        [_selectedCategoryCollectionView registerClass:[ProgramSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier];
        
        [self.view addSubview:_selectedCategoryCollectionView];
        
        self.categoryItems[self.selectedCategoryItem[@"related"]] = [[NSMutableArray alloc] init];
        
        NSDictionary * bindings = NSDictionaryOfVariableBindings(_selectedCategoryCollectionView);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_selectedCategoryCollectionView]|" options:0 metrics:nil views:bindings]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_selectedCategoryCollectionView]|" options:0 metrics:nil views:bindings]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.mode == ShopDetailModeNormal) {
        
        [self loadShopData];
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            
            UIBarButtonItem * drawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toggle-sidebar-icon"] style:UIBarButtonItemStyleBordered target:self action:@selector(didToggleSidebar:)];
            self.navigationItem.leftBarButtonItem = drawerButton;
            
        } else {
            
            UIBarButtonItem * drawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toggle-sidebar-icon-ios7"] style:UIBarButtonItemStyleBordered target:self action:@selector(didToggleSidebar:)];
            self.navigationItem.leftBarButtonItem = drawerButton;
            
            self.navigationController.navigationBar.translucent = NO;
        }
    } else {
        
        [self loadCategoryData];
        
        self.title = @"Related Items";
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshShop:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.categoryCollectionViewLayoutDone = NO;
    [self _layoutCollectionViews];
    
    [self.toolbar updateCartValue];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _collectionView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 92.0f);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    self.categoryCollectionViewLayoutDone = NO;
    [self _layoutCollectionViews];
}

- (void)_layoutCollectionViews {
    
    if(!_categoryCollectionViewLayoutDone) {
        
        CGFloat contentSizeWidthAccumulator = self.view.frame.size.width; // Add base collection view
        
        int i = 0;
        for(UICollectionView * collectionView in self.categoryCollectionViews) {
            
            collectionView.frame = CGRectMake((self.view.frame.size.width) * (i + 1), 0, self.view.frame.size.width, self.view.frame.size.height);
            contentSizeWidthAccumulator += collectionView.frame.size.width;
            i++;
        }
        _contentScrollView.contentSize = CGSizeMake(contentSizeWidthAccumulator, self.view.frame.size.height);
        
        self.categoryCollectionViewLayoutDone = YES;
        
        [self.contentScrollView setContentOffset:CGPointMake(self.view.frame.size.width * self.currentPageNumber, 0) animated:YES];
    }
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return [[self.fetchedResultsController sections] count];
    
    if(collectionView == self.collectionView) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    if(self.mode == ShopViewControllerModeNormal) {
        
        if(collectionView == self.collectionView) {
            
            if(section == 0) {
                return [self.items count];
            } else {
                return [self.categories count];
            }
            
        } else {
            
            NSInteger pageNumber = [self.categoryCollectionViews indexOfObject:collectionView];
            NSDictionary * categoryInformation = self.categories[pageNumber];
            NSArray * categoryItems = self.categoryItems[categoryInformation[@"name"]];
            
            return [categoryItems count];
        }
        
    } else { // Category mode
        return [self.categoryItems[self.selectedCategoryItem[@"related"]] count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ShopItemCell * cell = (ShopItemCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    
    NSDictionary * itemForCell = nil;
    
    if(self.mode == ShopViewControllerModeNormal) {
     
        if(indexPath.section == 0) {
            
            if(collectionView == self.collectionView) {
                itemForCell = self.items[indexPath.row];
                
            } else {
                
                NSInteger pageNumber = [self.categoryCollectionViews indexOfObject:collectionView];
                NSDictionary * categoryInformation = self.categories[pageNumber];
                NSArray * categoryItems = self.categoryItems[categoryInformation[@"name"]];
                
                itemForCell = categoryItems[indexPath.row];
            }
            cell.type = ShopItemCellTypeItem;
            
        } else {
            
            itemForCell = self.categories[indexPath.row];
            cell.type = ShopItemCellTypeCategory;
        }
        
    } else { // Category mode
        itemForCell = self.categoryItems[self.selectedCategoryItem[@"related"]][indexPath.row];
    }
    
    cell.itemDict = itemForCell;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if([kind isEqual:UICollectionElementKindSectionHeader]) {
        
        ProgramSectionHeaderView * headerView = (ProgramSectionHeaderView*)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderReuseIdentifier forIndexPath:indexPath];
        
        if(self.mode == ShopViewControllerModeNormal) {
            
            if(indexPath.section == 0) {
                
                if(collectionView == self.collectionView) {
                    headerView.titleLabel.text = @"Featured Items";
                    
                } else {
                    
                    NSInteger pageNumber = [self.categoryCollectionViews indexOfObject:collectionView];
                    NSDictionary * categoryInformation = self.categories[pageNumber];
                    headerView.titleLabel.text = categoryInformation[@"name"];
                }
                
            } else {
                headerView.titleLabel.text = @"Categories";
            }
            
        } else {
            headerView.titleLabel.text = self.selectedCategoryItem[@"category"];
        }
        
        return headerView;
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"didSelectItemAtIndexPath");
    
//    ShopItemCell *cell = (ShopItemCell*)[collectionView cellForItemAtIndexPath:indexPath];
//    cell.itemHighlightView.alpha = 1.0f;
//    [UIView animateWithDuration:0.3f
//                          delay:0
//                        options:(UIViewAnimationOptionAllowUserInteraction)
//                     animations:^{
//                         NSLog(@"animation start");
//                         cell.itemHighlightView.alpha = 0.0f;
//                     }
//                     completion:^(BOOL finished){
//                         NSLog(@"animation end");
//                     }
//     ];
    
    
    NSDictionary * itemForCell = nil;
    if(self.mode == ShopViewControllerModeNormal) {
     
        if(indexPath.section == 0) {
            
            if(collectionView == self.collectionView) {
                itemForCell = self.items[indexPath.row];
                
            } else {
                
                NSInteger pageNumber = [self.categoryCollectionViews indexOfObject:collectionView];
                NSDictionary * categoryInformation = self.categories[pageNumber];
                NSArray * categoryItems = self.categoryItems[categoryInformation[@"name"]];
                
                itemForCell = categoryItems[indexPath.row];
            }
            [self performSegueWithIdentifier:@"ShopItemSegue" sender:itemForCell];
            
        } else {
            
            NSInteger pageNumber = (indexPath.row + 1);
            [self.categoryToolbar selectButtonAtIndex:pageNumber shouldNotifyDelegate:YES animated:YES];
        }
        
    } else {
        itemForCell = self.categoryItems[self.selectedCategoryItem[@"related"]][indexPath.row];
        [self performSegueWithIdentifier:@"ShopItemSegue" sender:itemForCell];
    }

    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.mode == ShopViewControllerModeNormal) {
        if(indexPath.section == 0) {
            if(collectionView == self.collectionView) {
                return CGSizeMake(kProgramCellWidth, [ShopItemCell heightForShopItem:((NSDictionary*)self.items[indexPath.row])]);
                
            } else {
                
                NSInteger pageNumber = [self.categoryCollectionViews indexOfObject:collectionView];
                NSDictionary * categoryInformation = self.categories[pageNumber];
                NSArray * categoryItems = self.categoryItems[categoryInformation[@"name"]];
                
                return CGSizeMake(kProgramCellWidth, [ShopItemCell heightForShopItem:((NSDictionary*)categoryItems[indexPath.row])]);
            }
        } else {
            return CGSizeMake(kProgramCellWidth, kProgramCellHeight);
        }
    } else {
        
        NSDictionary * itemForCell = self.categoryItems[self.selectedCategoryItem[@"related"]][indexPath.row];
        return CGSizeMake(kProgramCellWidth, [ShopItemCell heightForShopItem:itemForCell]);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    if(section == 0 && collectionView == self.collectionView) {
        return UIEdgeInsetsMake(92.0f, 10, 10, 10);
    } else {
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.frame.size.width, 23);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShopItemSegue"]) {
        
        NSDictionary * selectedItem = (NSDictionary*)sender;
        ShopDetailViewController *detailViewController = [segue destinationViewController];
        detailViewController.selectedItem = selectedItem;
        
    } else if([segue.identifier isEqualToString:@"ShopLoginRequiredSegue"]) {
        
        UINavigationController * detailNavigationController = [segue destinationViewController];
        LoginViewController * controller = [detailNavigationController.viewControllers firstObject];
        controller.delegate = self;
    }
}

#pragma mark - Private Methods
- (void)loadShopData {
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
    
    ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
    [httpClient retrieveShopListing:^(NSDictionary * result) {
//        NSLog(@"completion");
        
        // We can assume the data is completely correct at this point, validation is done in ExersiteHTTPClient
        self.items = result[@"items"];
        self.categories = result[@"categories"];
        
        [self.collectionView reloadData];        
        
        // Create collectionview for each category, and entry in category toolbar
        NSMutableArray * mutableCategoryCollectionViews = [[NSMutableArray alloc] init];

        ShopCategoryToolbarButton * featuredButton = [[ShopCategoryToolbarButton alloc] init];
        [featuredButton setCategoryNameString:@"Featured"];
        [self.categoryToolbar addButton:featuredButton];
        
        int i = 0;
        for(NSDictionary * category in self.categories) {
            
            ShopCategoryToolbarButton * categoryToolbarButton = [[ShopCategoryToolbarButton alloc] init];
            [categoryToolbarButton setCategoryNameString:category[@"name"]];
            [self.categoryToolbar addButton:categoryToolbarButton];
            
            UICollectionView * categoryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
            
            categoryCollectionView.delegate = self;
            categoryCollectionView.dataSource = self;
            categoryCollectionView.backgroundColor = [UIColor clearColor];
            
            categoryCollectionView.contentInset = UIEdgeInsetsMake(44, 0, 44, 0);
            categoryCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
            
            [categoryCollectionView registerClass:[ShopItemCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
            [categoryCollectionView registerClass:[ProgramSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier];
            
            [_contentScrollView addSubview:categoryCollectionView];
            [mutableCategoryCollectionViews addObject:categoryCollectionView];
            
            self.categoryItems[category[@"name"]] = [[NSMutableArray alloc] init];
            
            i++;
        }
        
        self.categoryCollectionViews = mutableCategoryCollectionViews;
        
        [self _layoutCollectionViews];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [loadingView hide:YES];
    }];
}

- (void)loadCategoryData {
    
    if(!_selectedCategoryItem) {
//        NSLog(@"No category specified, aborting loadCategoryData");
        return;
    }
    
    [self.categoryItems removeAllObjects];
    
    MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
    
    ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
    [httpClient retrieveShopItemsForCategoryWithParameters:@{ @"category": self.selectedCategoryItem[@"related"] } completion:^(NSDictionary *result) {
        
        NSArray * categoryItems = result[@"items"];
        self.categoryItems[self.selectedCategoryItem[@"related"]] = [[NSMutableArray alloc] init];
        [self.categoryItems[self.selectedCategoryItem[@"related"]] addObjectsFromArray:categoryItems];
        
        // Find the origin item in related items and remove it
        NSDictionary * foundSelectedItem = nil;
        for(NSDictionary * item in self.categoryItems[self.selectedCategoryItem[@"related"]]) {
            if([item[@"url"] isEqualToString:self.selectedCategoryItem[@"url"]]) {
                foundSelectedItem = item;
            }
        }
        if(foundSelectedItem) {
            [self.categoryItems[self.selectedCategoryItem[@"related"]] removeObject:foundSelectedItem];
        }
        
        [_selectedCategoryCollectionView reloadData];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [loadingView hide:YES];
    }];
}

- (void)_checkSelectedCategoryLoadStatusForPage:(NSInteger)pageNumber {
    
    if(pageNumber == 0) { return; } // Page is featured, this is always loaded
    
    NSDictionary * selectedCategory = self.categories[pageNumber - 1];
    NSString * categoryName = selectedCategory[@"name"];
    
    if([self.categoryItems[categoryName] count] == 0) { // No items == not loaded
        
        MBProgressHUD * loadingView = [ProgressHUDHelper showLoadingHUDWithLabelText:nil withDetailsLabelText:nil];
        
//        NSLog(@"should load information for selected category: %@", selectedCategory[@"name"]);
        
        ExersiteHTTPClient * httpClient = [[ExersiteHTTPClient alloc] init];
        [httpClient retrieveShopItemsForCategoryWithParameters:@{ @"category": selectedCategory[@"short-name"] } completion:^(NSDictionary *result) {
            
            [self.categoryItems[categoryName] removeAllObjects];
            [self.categoryItems[categoryName] addObjectsFromArray:result[@"items"]];
            [self.categoryCollectionViews[pageNumber - 1] reloadData]; // Reload collectionview for category
            
            self.categoryCollectionViewLayoutDone = NO;
            [self _layoutCollectionViews];
            
            [loadingView hide:YES];
            
//            NSLog(@"response for category");
        }];
    }
}

- (void)refreshShop:(id)sender {
    
    if(self.mode == ShopViewControllerModeNormal) {
        
        [self.categoryToolbar clearState];
        [self.contentScrollView setContentOffset:CGPointZero animated:YES];
        
        for(UICollectionView * categoryCollectionView in self.categoryCollectionViews) {
            [categoryCollectionView removeFromSuperview];
        }
        _categoryCollectionViews = nil;
        
        self.currentPageNumber = 0;
        
        [self loadShopData];
        
    } else {
        [self loadCategoryData];
    }
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView_ {
    
    if(scrollView_ == self.contentScrollView) { // Should not respond to UICollectionView move events
        int pageNumber = (scrollView_.contentOffset.x / self.view.frame.size.width);
        [self.categoryToolbar selectButtonAtIndex:pageNumber shouldNotifyDelegate:NO animated:YES];
        
        [self _checkSelectedCategoryLoadStatusForPage:pageNumber];
        [self setCurrentPageNumber:pageNumber];
    }
}

#pragma mark - ShopCategoryToolbarDelegate Methods
- (void)shopCategoryToolbar:(ShopCategoryToolbar*)toolbar didChangeToCategoryAtIndex:(NSNumber*)index {
    
    [self.contentScrollView setContentOffset:CGPointMake(self.view.frame.size.width * [index intValue], 0) animated:YES];
    [self _checkSelectedCategoryLoadStatusForPage:[index intValue]];
    [self setCurrentPageNumber:[index intValue]];
}

- (void)shopCategoryToolbar:(ShopCategoryToolbar*)toolbar didTapSearchButton:(UIButton*)button {
    [self performSegueWithIdentifier:@"ShopSearchSegue" sender:button];
}

#pragma mark - ShopShippingInformationHeaderDelegate Methods
- (void)shopShippingInformationHeader:(ShopShippingInformationHeaderView*)headerView didSelectRequestQuoteButton:(UIButton*)button {
    [self performSegueWithIdentifier:@"ShopRequestQuoteSegue" sender:button];
}

#pragma mark - ShopCartOrdersDelegate Methods
- (void)shopCartOrdersToolbar:(ShopCartOrdersToolbar*)toolbar didTapOrdersButton:(UIButton*)button {
    
    //ShopLoginRequiredSegue if user is not logged in
    if([[ExersiteSession currentSession] isUserLoggedIn]) {
        [self performSegueWithIdentifier:@"ShopOrdersSegue" sender:button];
    } else {
        [self performSegueWithIdentifier:@"ShopLoginRequiredSegue" sender:button];
    }
}

- (void)shopCartOrdersToolbar:(ShopCartOrdersToolbar*)toolbar didTapCartButton:(UIButton*)button {
    [self performSegueWithIdentifier:@"ShopCartSegue" sender:button];
}

#pragma mark - LoginViewControllerDelegate Methods
- (void)loginViewControllerDidLogin:(LoginViewController*)controller {
    
    // This is only executed when user is trying to access orders, while unauthorised,
    // so it doesn't matter if we hardcode it to loading the orders controller
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"ShopOrdersSegue" sender:nil];
    }];
}

@end
