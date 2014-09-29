//
//  ShopSearchViewController.m
//  Exersite
//
//  Created by James Eunson on 21/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ShopSearchViewController.h"
#import "ExersiteHTTPClient.h"
#import "ShopDetailViewController.h"
#import "ProgramSectionHeaderView.h"
#import "UIImageView+AFNetworking.h"
#import "ShopSearchEmptyView.h"

@interface ShopSearchViewController ()

@property (nonatomic, strong) ExersiteHTTPClient * httpClient;
@property (nonatomic, strong) ShopSearchEmptyView * emptyView;

@end

@implementation ShopSearchViewController


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.httpClient = [[ExersiteHTTPClient alloc] init];
        self.searchResults = [[OrderedDictionary alloc] init];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    
    self.view.backgroundColor = RGBCOLOR(238, 238, 238);
    
    self.searchBar = [[UISearchBar alloc] init];
    _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    _searchBar.delegate = self;
    _searchBar.placeholder = @"Search Exersite Shop";
    
    [self.view addSubview:_searchBar];
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
	[self.searchController setDelegate:self];
	[self.searchController setSearchResultsDataSource:self];
	[self.searchController setSearchResultsDelegate:self];
    
    self.emptyView = [[ShopSearchEmptyView alloc] init];
    _emptyView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_emptyView];
    
    NSDictionary * bindings = NSDictionaryOfVariableBindings(_searchBar, _emptyView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_searchBar]|" options:0 metrics:nil views:bindings]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_emptyView]|" options:0 metrics:nil views:bindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_searchBar]-0-[_emptyView]|" options:0 metrics:nil views:bindings]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewControllerAnimated:)];
    
    self.title = @"Search Shop";
    
    if (!(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)) {
        self.navigationController.navigationBar.translucent = NO;
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString * keyForSection = [self.searchResults allKeys][section];
    return [self.searchResults[keyForSection] count];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.searchResults allKeys] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * keyForSection = [self.searchResults allKeys][indexPath.section];
    NSDictionary * item = self.searchResults[keyForSection][indexPath.row];
    
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    cell.textLabel.text = item[@"name"];

    cell.detailTextLabel.text = [NSString stringWithFormat:@"$A%.2f", [item[@"price"] floatValue]];
    cell.detailTextLabel.textColor = kTintColour;
    
    __block UITableViewCell * blockCell = cell;
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:item[@"thumb"]]];
    
    [cell.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        blockCell.imageView.image = image;
        [blockCell setNeedsLayout];
    } failure:nil];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.searchResults allKeys][section];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    ProgramSectionHeaderView * headerView = [[ProgramSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 23)];
    headerView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * keyForSection = [self.searchResults allKeys][indexPath.section];
    NSDictionary * item = self.searchResults[keyForSection][indexPath.row];
    
    [self performSegueWithIdentifier:@"ShopSearchItemSegue" sender:item];
}

#pragma mark - UISearchBarDelegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    NSLog(@"search start: %@", searchBar.text);
    
    [self.httpClient searchShopWithQuery:searchBar.text completion:^(NSDictionary *result) {
        if(result) {
//            NSLog(@"result");
            
            NSArray * results = result[@"results"];
//            results = [results sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                
//            }];
            
            for(NSDictionary * item in results) {
                if(![[_searchResults allKeys] containsObject:item[@"category"]]) {
                    _searchResults[item[@"category"]] = [[NSMutableArray alloc] init];
                }
                NSMutableArray * itemsForCategory = _searchResults[item[@"category"]];
                [itemsForCategory addObject:item];
            }
            [self.searchController.searchResultsTableView reloadData];
            
        } else {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to retrieve search results. Please check your connection and try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

#pragma mark - UISearchDisplayControllerDelegate Methods
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    tableView.separatorInset = UIEdgeInsetsZero;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self.searchResults removeAllObjects];
    return NO;
}

#pragma mark - Private Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShopSearchItemSegue"]) {
        
        ShopDetailViewController * detailViewController = segue.destinationViewController;
        detailViewController.selectedItem = ((NSDictionary*)sender);
    }
}

@end
