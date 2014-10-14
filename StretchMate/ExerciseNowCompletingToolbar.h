//
//  ExerciseNowCompletingToolbar.h
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseNowCompletingButtonsView.h"
#import "ExerciseBigButton.h"

// Determines the height of the toolbar, and which elements are visible,
// Page navigation-related elements are not shown for a single exercise (next, previous buttons, etc)
typedef enum {
    ExerciseNowCompletingToolbarTypeSingleExercise,
    ExerciseNowCompletingToolbarTypeMultipleExercises
} ExerciseNowCompletingToolbarType;

#define kNowCompletingToolbarSingleExerciseHeight 44.0f
#define kNowCompletingToolbarMultipleExercisesHeight 96.0f

@protocol ExerciseNowCompletingToolbarDelegate;
@interface ExerciseNowCompletingToolbar : UIToolbar

@property (nonatomic, assign) ExerciseNowCompletingToolbarType type;

@property (nonatomic, assign) __unsafe_unretained id<ExerciseNowCompletingToolbarDelegate> nowCompletingToolbarDelegate;

@property (nonatomic, strong) UIView * timeContainerView;
@property (nonatomic, strong) UIImageView * timeImageView;
@property (nonatomic, strong) UILabel * timeLabel;

@property (nonatomic, strong) NSArray * programExercises;
@property (nonatomic, strong) id selectedExercise;

@property (nonatomic, strong) ExerciseBigButton * finishedButton;

@property (nonatomic, strong) ExerciseNowCompletingButtonsView * buttonsView;

@property (nonatomic, strong) UIView * progressView;

@property (nonatomic, strong) CALayer * dividerBorder;
@property (nonatomic, strong) UILabel * previousExerciseLabel;
@property (nonatomic, strong) UILabel * nextExerciseLabel;
@property (nonatomic, strong) UILabel * positionLabel;

// Timer elements
@property (nonatomic, strong) NSTimer * refreshTimer;
@property (nonatomic, assign) NSInteger remainingSeconds;
@property (nonatomic, assign) NSInteger totalSeconds;
@property (nonatomic, assign, getter = isPaused) BOOL paused;

@property (nonatomic, strong) NSNumber* recordedTime;

- (void)toggleTimerWithStartStopButton:(ExerciseNowCompletingStartPauseButton*)button;
- (void)updateInterfaceAfterPageChange;
- (void)resetFinishedButton;

@end

@protocol ExerciseNowCompletingToolbarDelegate <NSObject>
@required
- (void)exerciseNowCompletingToolbar:(ExerciseNowCompletingToolbar*)toolbar didTapStartPauseButton:(UIButton*)startPauseButton;
@optional
- (void)exerciseNowCompletingToolbar:(ExerciseNowCompletingToolbar*)toolbar didTapPreviousButton:(UIButton*)previousButton;
- (void)exerciseNowCompletingToolbar:(ExerciseNowCompletingToolbar*)toolbar didTapNextButton:(UIButton*)nextButton;
- (void)exerciseNowCompletingToolbar:(ExerciseNowCompletingToolbar*)toolbar didTapFinishedButton:(UIButton*)finishedButton;

@end