//
//  MyPractitionerViewController.h
//  Exersite
//
//  Created by James Eunson on 7/09/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPractitionerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSDictionary * practitionerInformation;

@end
