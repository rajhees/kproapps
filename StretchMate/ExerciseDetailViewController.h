//
//  ExerciseDetailViewController.h
//  StretchMate
//
//  Created by James Eunson on 24/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exercise.h"
#import "ExerciseDetailScrollView.h"
#import "ExerciseCleanDetailScrollView.h"

@interface ExerciseDetailViewController : UIViewController <ExerciseCleanDetailScrollViewDelegate, ExerciseDetailScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) id selectedExercise;
@property (nonatomic, strong) ExerciseCleanDetailScrollView * scrollView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem * actionBarButtonItem;

@property (nonatomic, strong) UILabel * prescribedLabel;
@property (nonatomic, strong) UIToolbar * prescribedNotificationToolbar;
@property (nonatomic, strong) CALayer * prescribedNotificationToolbarBorder;

@property (nonatomic, assign) BOOL viewingFromPrescriptionProgram;

@end
