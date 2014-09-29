//
//  ExerciseNowCompletingView.h
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseMediaView.h"
#import "ExerciseInstructionTableView.h"

typedef enum {
    ExerciseNowCompletingViewTypeSingle,
    ExerciseNowCompletingViewTypeMultiple
} ExerciseNowCompletingViewType;

@protocol ExerciseNowCompletingViewDelegate;
@interface ExerciseNowCompletingView : UIView <ExerciseMediaViewDelegate, ExerciseInstructionTableViewSelectedRowChangeDelegate>

@property (nonatomic, assign) __unsafe_unretained id<ExerciseNowCompletingViewDelegate> delegate;

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * completionSubtitleLabel;

@property (nonatomic, strong) ExerciseMediaView * mediaView;

@property (nonatomic, strong) id selectedExercise;

@property (nonatomic, strong) CALayer * instructionsTableViewTopBorder;
@property (nonatomic, strong) ExerciseInstructionTableView * instructionsTableView;

@property (nonatomic, assign) ExerciseNowCompletingViewType type;

@property (nonatomic, strong) UIToolbar * startFinishHintToolbar;
@property (nonatomic, strong) UILabel * startFinishHintLabel;

@end

@protocol ExerciseNowCompletingViewDelegate <NSObject>
@required
- (void)exerciseNowCompletingView:(ExerciseMediaView*)scrollView didTapImageViewWithParameters:(NSDictionary*)parameters;
@end