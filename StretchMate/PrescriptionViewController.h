//
//  PrescriptionViewController.h
//  StretchMate
//
//  Created by James Eunson on 23/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrescriptionNotLoggedInView.h"
#import "PrescriptionEmptyView.h"
#import "LoginViewController.h"

@interface PrescriptionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, PrescriptionNotLoggedInViewDelegate, LoginControllerDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, strong) NSArray * prescribedPrograms;

@property (nonatomic, strong) PrescriptionNotLoggedInView * notLoggedInView;
@property (nonatomic, strong) PrescriptionEmptyView * emptyView;

@end
