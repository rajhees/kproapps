//
//  ShopSearchViewController.h
//  Exersite
//
//  Created by James Eunson on 21/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderedDictionary.h"

@interface ShopSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UISearchDisplayController * searchController;
@property (nonatomic, strong) UISearchBar * searchBar;

@property (nonatomic, strong) OrderedDictionary * searchResults;

@end
