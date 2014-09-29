//
//  ProgramListingViewController.h
//  StretchMate
//
//  Created by James Eunson on 16/02/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Program.h"

@interface ProgramListingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) id selectedProgram; // Accepts either NSDictionary or Program object

@property (nonatomic, strong) NSArray * programExercises;
@property (nonatomic, strong) NSArray * savedExercises;
@property (nonatomic, strong) UITableView * tableView;

@end
