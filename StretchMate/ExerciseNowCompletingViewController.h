//
//  ExerciseNowCompletingViewController.h
//  StretchMate
//
//  Created by James Eunson on 6/03/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exercise.h"
#import "ExerciseNowCompletingPageViewController.h"
#import "ExerciseNowCompletingView.h"
#import "ExerciseNowCompletingToolbar.h"
#import "PrescriptionNowCompletingCompleteView.h"

typedef enum {
    ExerciseNowCompletingViewControllerModeSingle,
    ExerciseNowCompletingViewControllerModeMultiple
} ExerciseNowCompletingViewControllerMode;

@protocol ExerciseNowCompletingPageDelegate;
@interface ExerciseNowCompletingViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate, ExerciseNowCompletingViewDelegate, ExerciseNowCompletingToolbarDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) id selectedExercise;

@property (nonatomic, strong) ExerciseNowCompletingView * nowCompletingView;
@property (nonatomic, strong) ExerciseNowCompletingToolbar * nowCompletingToolbar;

// Timer elements
@property (nonatomic, strong) NSTimer * refreshTimer;
@property (nonatomic, assign) NSInteger remainingSeconds;
@property (nonatomic, assign) NSInteger totalSeconds;
@property (nonatomic, assign, getter = isPaused) BOOL paused;

@property (nonatomic, assign) ExerciseNowCompletingViewControllerMode mode;
@property (nonatomic, assign) __unsafe_unretained id<ExerciseNowCompletingPageDelegate> delegate;

@property (nonatomic, assign, getter = isCompleteInPrescriptionExercises) BOOL completeInPrescriptionExercises;
@property (nonatomic, strong) PrescriptionNowCompletingCompleteView * completeView;

- (id)initWithMode:(ExerciseNowCompletingViewControllerMode)mode;

@end

@protocol ExerciseNowCompletingPageDelegate <NSObject>
@required
- (void)exerciseNowCompletingViewController:(ExerciseNowCompletingViewController*)controller didTapImageViewWithParameters:(NSDictionary*)parameters;
@end
