//
//  ExerciseMediaView.h
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StyledPageControl.h"
#import "ExerciseNowCompletingStepButton.h"

// Two separate modes, normal mode has segmented control that selects images or video
// NowCompletingSteps mode replaces the segmented control with a next/previous stepper
typedef enum {
    ExerciseMediaViewTypeNormal,
    ExerciseMediaViewTypeNowCompletingSteps
} ExerciseMediaViewType;

typedef enum {
    ExerciseMediaViewDirectionPrevious,
    ExerciseMediaViewDirectionNext
} ExerciseMediaViewDirection;

#define kExerciseMediaContainerHeight 240.0f
#define kExerciseMediaNowCompletingContainerHeight 229.0f
#define kExerciseMediaScrollViewHeight 180.0f

#define kExerciseMediaContainerPractitionerExerciseHeight 196.0f

@protocol ExerciseMediaViewDelegate;
@interface ExerciseMediaView : UIView <UIScrollViewDelegate>

@property (nonatomic, strong) id selectedExercise;
@property (nonatomic, assign) ExerciseMediaViewType type;

@property (nonatomic, strong) CALayer * mediaContainerTopBorder;
@property (nonatomic, strong) CALayer * mediaContainerBottomBorder;

@property (nonatomic, strong) UIButton * mediaZoomButton;
@property (nonatomic, strong) UIView * mediaContainerView;
@property (nonatomic, strong) UIScrollView * mediaScrollView;
@property (nonatomic, strong) UIButton * mediaEnlargeButton;

@property (nonatomic, strong) UIView * mediaPageControlContainerView;
@property (nonatomic, strong) StyledPageControl * mediaPageControl;

@property (nonatomic, strong) CALayer * mediaContainerSegmentedControlBorder;
@property (nonatomic, strong) UISegmentedControl * mediaSegmentedControl;

@property (nonatomic, strong) MPMoviePlayerController * playerController;

@property (nonatomic, strong) UIImageView * noImageAvailableImageView;
@property (nonatomic, strong) UILabel * noImageAvailableLabel;

@property (nonatomic, strong) ExerciseNowCompletingStepButton * previousStepButton;
@property (nonatomic, strong) ExerciseNowCompletingStepButton * nextStepButton;

@property (nonatomic, assign) __unsafe_unretained id<ExerciseMediaViewDelegate> delegate;

- (void)updateMediaScrollViewContentOffset;

- (void)setPreviousStepButtonEnabled:(BOOL)previousStepButtonEnabled;
- (void)setNextStepButtonEnabled:(BOOL)nextStepButtonEnabled;

@end

@protocol ExerciseMediaViewDelegate <NSObject>
@required
- (void)exerciseMediaView:(ExerciseMediaView*)scrollView didTapImageViewWithParameters:(NSDictionary*)parameters;
- (void)exerciseMediaView:(ExerciseMediaView*)scrollView didTapDirectionButtonWithDirection:(NSNumber*)direction;
@end
