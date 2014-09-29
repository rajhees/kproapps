//
//  PrescriptionProgramViewController.h
//  Exersite
//
//  Created by James Eunson on 21/08/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderedDictionary.h"

typedef enum {
    PrescriptionProgramViewControllerModeAll,
    PrescriptionProgramViewControllerModeDay
} PrescriptionProgramViewControllerMode;

@interface PrescriptionProgramViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel * monthYearLabel;
@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) id selectedProgram;
@property (nonatomic, strong) NSArray * programExercises;
@property (nonatomic, assign) NSInteger programIndex;

@property (nonatomic, strong) NSDate * currentDay;
@property (nonatomic, strong) OrderedDictionary * allExercisesByTimeslot; // Used in the preparation of each of the below

@property (nonatomic, strong) OrderedDictionary * currentDayExercises;
@property (nonatomic, strong) OrderedDictionary * allExercisesByDay;

@property (nonatomic, assign) PrescriptionProgramViewControllerMode mode;

@end
