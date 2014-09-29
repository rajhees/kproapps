//
//  ExerciseNowCompletingStartPauseButton.h
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ExerciseNowCompletingStartPauseButtonModePaused,
    ExerciseNowCompletingStartPauseButtonModePlaying
} ExerciseNowCompletingStartPauseButtonMode;

@interface ExerciseNowCompletingStartPauseButton : UIButton

@property (nonatomic, strong) UIImageView * startImageView;
@property (nonatomic, strong) UILabel * startLabel;

@property (nonatomic, strong) UIImageView * pauseImageView;
@property (nonatomic, strong) UILabel * pauseLabel;

@property (nonatomic, strong) UIView * startPauseBackgroundView;

@property (nonatomic, assign) ExerciseNowCompletingStartPauseButtonMode startPauseState;

@property (nonatomic, assign) BOOL startPauseEnabled;

@end
