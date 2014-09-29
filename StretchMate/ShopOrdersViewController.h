//
//  ShopOrdersViewController.h
//  Exersite
//
//  Created by James Eunson on 22/10/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kOrderDate @"orderDate"
#define kOrderHumanReadableDayDate @"orderHumanReadableDayDate"

@interface ShopOrdersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView * tableView;

@end
