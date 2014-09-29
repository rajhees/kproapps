//
//  ExerciseInstructionTableView.h
//  StretchMate
//
//  Created by James Eunson on 9/03/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exercise.h"

typedef enum {
    ExerciseInstructionTableViewModeNormal,
    ExerciseInstructionTableViewModeCompleting
} ExerciseInstructionTableViewMode;

@protocol ExerciseInstructionTableViewSelectedRowChangeDelegate;
@interface ExerciseInstructionTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) id selectedExercise;
@property (nonatomic, assign) ExerciseInstructionTableViewMode mode;
@property (nonatomic, strong) NSIndexPath * currentlySelectedIndexPath;

@property (nonatomic, assign) __unsafe_unretained id<ExerciseInstructionTableViewSelectedRowChangeDelegate> rowChangeDelegate;

- (id)initWithFrame:(CGRect)frame selectedExercise:(id)selectedExercise mode:(ExerciseInstructionTableViewMode)mode;

+ (CGFloat)heightForInstructionsTableViewWithExercise:(id)exercise;

- (void)updateSelectedIndexPath:(NSIndexPath*)indexPath shouldScrollToNewIndexPath:(BOOL)shouldScrollToNextIndexPath shouldNotifyDelegate:(BOOL)shouldNotify;

@end

@protocol ExerciseInstructionTableViewSelectedRowChangeDelegate <NSObject>
- (void)exerciseInstructionTableView:(ExerciseInstructionTableView*)tableView selectedRowDidChangeToNewIndexPath:(NSIndexPath*)row;
@end