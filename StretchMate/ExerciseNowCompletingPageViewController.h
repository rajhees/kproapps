//
//  ExerciseNowCompletingPageViewController.h
//  StretchMate
//
//  Created by James Eunson on 17/04/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exercise.h"
#import "ExerciseNowCompletingViewController.h"
#import "ExerciseNowCompletingToolbar.h"

@protocol ExerciseNowCompletingPageDelegate;
@interface ExerciseNowCompletingPageViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, ExerciseNowCompletingToolbarDelegate, ExerciseNowCompletingPageDelegate>

@property (nonatomic, strong) UIPageViewController * pageViewController;
@property (nonatomic, strong) Exercise * selectedExercise;

@property (nonatomic, strong) NSMutableArray * prescriptionProgramExercises;
@property (nonatomic, strong) NSArray * programExercises;

@property (nonatomic, strong) ExerciseNowCompletingToolbar * nowCompletingToolbar;

@property (nonatomic, assign, getter = isPageTurnEnabled) BOOL pageTurnEnabled;

- (id)initWithProgramExercises:(NSArray*)programExercises;
- (id)initWithPrescriptionProgramExercises:(NSArray*)prescriptionProgramExercises;

@end

