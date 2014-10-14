//
//  ExerciseNowCompletingToolbar.m
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseNowCompletingToolbar.h"
#import "Exercise.h"
#import "ProgressHUDHelper.h"

@interface ExerciseNowCompletingToolbar ()
{
    int _privateRecordedTime;
}

- (void)didTapPreviousButton:(id)sender;
- (void)didTapNextButton:(id)sender;
- (void)didTapStartPauseButton:(id)sender;
- (void)didTapFinishedButton:(id)sender;

- (void)timerUpdateInterface:(id)sender;
- (void)updateTimerInternal;

- (void)resetTimerState;

@end


@implementation ExerciseNowCompletingToolbar

- (id)init {
    self = [super init];
    if(self) {
        
        _privateRecordedTime = 0;
        
        self.translucent = YES;
        self.barTintColor = RGBCOLOR(238, 238, 238);
        
        self.userInteractionEnabled = YES;
        
        self.timeContainerView = [[UIView alloc] init];
        _timeContainerView.backgroundColor = [UIColor whiteColor];
        _timeContainerView.layer.cornerRadius = 4.0f;
        _timeContainerView.layer.borderColor = [RGBCOLOR(180, 180, 180) CGColor];
        _timeContainerView.layer.borderWidth = 1.0f;
        [self addSubview:_timeContainerView];
        
        self.timeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-now-completing-clock-icon-ios7"]];
        [_timeContainerView addSubview:_timeImageView];
        
        self.timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = RGBCOLOR(57, 58, 70);
        _timeLabel.font = [UIFont systemFontOfSize:18.0f];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.text = @"1:00";
        [_timeContainerView addSubview:_timeLabel];
        
        self.progressView = [[UIView alloc] init];
        _progressView.backgroundColor = kTintColour;
        _progressView.frame = CGRectMake(0, 0, 0, 2.0f);
        [self addSubview:_progressView];
        
        self.finishedButton = [[ExerciseBigButton alloc] init];
        _finishedButton.exerciseButtonType = ExerciseBigButtonTypeImFinished;
        [_finishedButton addTarget:self action:@selector(didTapFinishedButton:) forControlEvents:UIControlEventTouchUpInside];
        _finishedButton.alpha = 0.5f;
        _finishedButton.enabled = NO;
        [self addSubview:_finishedButton];
        
        self.buttonsView = [[ExerciseNowCompletingButtonsView alloc] init];
        
        [self.buttonsView.previousButton setDirectionButtonEnabled:NO];
        [self.buttonsView.nextButton setDirectionButtonEnabled:NO];
        
        // Bindings so that buttons call delegate methods in ExerciseNowCompletingToolbarDelegate
        [self.buttonsView.previousButton addTarget:self action:@selector(didTapPreviousButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonsView.nextButton addTarget:self action:@selector(didTapNextButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonsView.startPauseButton addTarget:self action:@selector(didTapStartPauseButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_buttonsView];
        
        self.paused = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _timeContainerView.frame = CGRectMake(6.0f, 6.0f, 75.0f, 44.0f - (12.0f));
    _timeImageView.frame = CGRectMake(6.0f, (_timeContainerView.frame.size.height / 2) - (_timeImageView.frame.size.height / 2), _timeImageView.frame.size.width, _timeImageView.frame.size.height);
    
    _timeLabel.frame = CGRectMake(_timeImageView.frame.size.width + 8.0f, 0, _timeContainerView.frame.size.width - _timeImageView.frame.size.width - 8.0f, _timeContainerView.frame.size.height);
    
    _buttonsView.frame = CGRectMake(self.frame.size.width - 204.0f - 6.0f, 6.0f, 204.0f, 44.0f - (12.0f));
    
    _finishedButton.frame = CGRectMake(8.0f, _buttonsView.frame.origin.y + _buttonsView.frame.size.height + 8.0f, self.frame.size.width - 16.0f, 44.0f);
}

- (CGSize)intrinsicContentSize {
//    if(self.type == ExerciseNowCompletingToolbarTypeSingleExercise) {
//        return CGSizeMake(UIViewNoIntrinsicMetric, kNowCompletingToolbarSingleExerciseHeight);
//    } else {
//        return CGSizeMake(UIViewNoIntrinsicMetric, kNowCompletingToolbarMultipleExercisesHeight);
//    }
    return CGSizeMake(UIViewNoIntrinsicMetric, kNowCompletingToolbarMultipleExercisesHeight);    
}

- (void)timerUpdateInterface:(id)sender {
//    NSLog(@"timerUpdateInterface");
    
    if(self.remainingSeconds == 0) { // completely reset state
        
        [self resetTimerState];
        [self updateInterfaceAfterPageChange];
        
    } else {
        
        self.remainingSeconds--;
    }
    
    // Save Recorded Time.
    _privateRecordedTime++;
    self.recordedTime = @(_privateRecordedTime);
    
    [self updateTimerInternal];
}

- (void)toggleTimerWithStartStopButton:(ExerciseNowCompletingStartPauseButton*)button {
    
    if(button.startPauseState == ExerciseNowCompletingStartPauseButtonModePaused) { // Paused
        
        self.paused = YES;
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
        
    } else { // Playing
        
        self.paused = NO;
        if(self.remainingSeconds > 0) {
            self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerUpdateInterface:) userInfo:nil repeats:YES];
        }
    }
}

- (void)updateInterfaceAfterPageChange {
    
    NSInteger indexOfCurrentlyVisiblePage = [self.programExercises indexOfObject:_selectedExercise];
    
    if(indexOfCurrentlyVisiblePage == 0) { // First page
        
        [self.buttonsView.previousButton setDirectionButtonEnabled:NO];
        [self.buttonsView.nextButton setDirectionButtonEnabled:YES];
        
    } else if(indexOfCurrentlyVisiblePage == ([self.programExercises count] - 1)) { // Last page
        
        [self.buttonsView.previousButton setDirectionButtonEnabled:YES];
        [self.buttonsView.nextButton setDirectionButtonEnabled:NO];
        
    } else {
        
        [self.buttonsView.previousButton setDirectionButtonEnabled:YES];
        [self.buttonsView.nextButton setDirectionButtonEnabled:YES];
    }
}

- (void)resetFinishedButton {
    _finishedButton.alpha = 0.5f;
    _finishedButton.enabled = NO;
}

#pragma mark - Property Override Methods
- (void)setType:(ExerciseNowCompletingToolbarType)type {
    _type = type;
    
    if(type == ExerciseNowCompletingToolbarTypeSingleExercise) {
        
        [self.buttonsView.previousButton setDirectionButtonEnabled:NO];
        [self.buttonsView.nextButton setDirectionButtonEnabled:NO];
        
    } else {
        [self.buttonsView.previousButton setDirectionButtonEnabled:NO];
        [self.buttonsView.nextButton setDirectionButtonEnabled:YES];
    }
    
    [self invalidateIntrinsicContentSize];
}

- (void)setSelectedExercise:(id)selectedExercise {
    _selectedExercise = selectedExercise;
    
    self.totalSeconds = [((Exercise*)self.selectedExercise).seconds integerValue];
    self.remainingSeconds = [((Exercise*)self.selectedExercise).seconds integerValue];
    
    // Initialize timer with exercise duration
    [self updateTimerInternal];
}

- (void)setPaused:(BOOL)paused {
    _paused = paused;
    
    if(!paused && !self.finishedButton.enabled) {
        _finishedButton.enabled = YES;
        _finishedButton.alpha = 1.0f;
    }
}

#pragma mark - Private Methods
- (void)updateTimerInternal {
    
    float minutesFloat = (((float)self.remainingSeconds) / 60.0f);
    NSString * minutesString = [NSString stringWithFormat:@"%d", (int)(minutesFloat)];
    
    NSString * secondsString = nil;
    int seconds = self.remainingSeconds % 60;
    if(seconds < 10) {
        secondsString = [NSString stringWithFormat:@"0%d", seconds];
    } else {
        secondsString = [NSString stringWithFormat:@"%d", seconds];
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@", minutesString, secondsString];
    
    if(self.remainingSeconds == 0 && self.totalSeconds == 0) {
        return;
    }
    
    float percentageDone = 1.0f - ((float)self.remainingSeconds / (float)self.totalSeconds);
    CGFloat progressBarWidthForPercentage = roundf(percentageDone * self.frame.size.width);
//    NSLog(@"progressBarWidthForPercentage: %f", progressBarWidthForPercentage);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.progressView.frame = CGRectMake(0, 0, progressBarWidthForPercentage, 2);
    }];
}

- (void)resetTimerState {
    
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
    self.paused = YES;
    
    self.remainingSeconds = [((Exercise*)_selectedExercise).seconds integerValue];
    self.totalSeconds = [((Exercise*)_selectedExercise).seconds integerValue];
    self.buttonsView.startPauseButton.startPauseState = ExerciseNowCompletingStartPauseButtonModePaused;
}

- (void)didTapPreviousButton:(id)sender {
    
    ExerciseNowCompletingDirectionButton * button = (ExerciseNowCompletingDirectionButton*)sender;
    
    if(button.directionButtonEnabled) {
        if([self.nowCompletingToolbarDelegate respondsToSelector:@selector(exerciseNowCompletingToolbar:didTapPreviousButton:)]) {
            [self.nowCompletingToolbarDelegate performSelector:@selector(exerciseNowCompletingToolbar:didTapPreviousButton:) withObject:self withObject:self];
        }
        
    } else {
        
        // Disabled, because the exercise is currently running (!isPaused), and we are in a multiple exercise context, where
        // changing to the previous exercise would otherwise be possible (the current item is not the first item)
        NSInteger indexOfSelectedExercise = [self.programExercises indexOfObject:_selectedExercise];
//        NSLog(@"selectedExercise: %@, position: %d", _selectedExercise, indexOfSelectedExercise);
        
        if(![self isPaused] && self.type == ExerciseNowCompletingToolbarTypeMultipleExercises && [self.programExercises indexOfObject:_selectedExercise] != 0) {
//            NSLog(@"tapped ExerciseNowCompletingDirectionButton when not enabled, FIRE WARNING");
            
            [ProgressHUDHelper showConfirmationHUDWithImage:nil withLabelText:@"Pause to change exercise." withDetailsLabelText:nil withFadeTime:1.5];
        }

    }
}

- (void)didTapNextButton:(id)sender {
    
    ExerciseNowCompletingDirectionButton * button = (ExerciseNowCompletingDirectionButton*)sender;
    
    if(button.directionButtonEnabled) {
        if([self.nowCompletingToolbarDelegate respondsToSelector:@selector(exerciseNowCompletingToolbar:didTapNextButton:)]) {
            [self.nowCompletingToolbarDelegate performSelector:@selector(exerciseNowCompletingToolbar:didTapNextButton:) withObject:self withObject:self];
        }
    } else {
        
        // Disabled, because the exercise is currently running (!isPaused), and we are in a multiple exercise context, where
        // changing to the next exercise would otherwise be possible (the current item is not the last)
        
        if(![self isPaused] && self.type == ExerciseNowCompletingToolbarTypeMultipleExercises && [self.programExercises indexOfObject:_selectedExercise] != ([self.programExercises count] - 1)) {
            
            [ProgressHUDHelper showConfirmationHUDWithImage:nil withLabelText:@"Pause to change exercise." withDetailsLabelText:nil withFadeTime:1.0];
        }
    }
}

- (void)didTapStartPauseButton:(id)sender {
    [self toggleTimerWithStartStopButton:sender];
    
    // Save Recorded Time.
    
    
    if([self.nowCompletingToolbarDelegate respondsToSelector:@selector(exerciseNowCompletingToolbar:didTapStartPauseButton:)]) {
        [self.nowCompletingToolbarDelegate performSelector:@selector(exerciseNowCompletingToolbar:didTapStartPauseButton:) withObject:self withObject:sender];
    }
}

- (void)didTapFinishedButton:(id)sender {
//    NSLog(@"didTapFinishedButton:");
    
//    [self toggleTimerWithStartStopButton:sender];
    
    NSLog(@"Time Recorded = %d", _privateRecordedTime);
    
    [self resetTimerState];
    
    if([self.nowCompletingToolbarDelegate respondsToSelector:@selector(exerciseNowCompletingToolbar:didTapFinishedButton:)]) {
        [self.nowCompletingToolbarDelegate performSelector:@selector(exerciseNowCompletingToolbar:didTapFinishedButton:) withObject:self withObject:sender];
    }
}


@end
