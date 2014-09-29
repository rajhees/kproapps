//
//  ExerciseNowCompletingStartPauseButton.m
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseNowCompletingStartPauseButton.h"

@interface ExerciseNowCompletingStartPauseButton ()
- (void)didTapSelf:(id)sender;
@end

@implementation ExerciseNowCompletingStartPauseButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = RGBCOLOR(180, 180, 180);
        
        self.startPauseBackgroundView = [[UIView alloc] init];
        _startPauseBackgroundView.backgroundColor = kTintColour;
        _startPauseBackgroundView.userInteractionEnabled = NO;
        [self addSubview:_startPauseBackgroundView];
        
        [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveEaseInOut animations:^{
            _startPauseBackgroundView.alpha = 0;
        } completion:nil];
        
        self.startImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-now-completing-start-icon-ios7"]];
        [self addSubview:_startImageView];
        
        self.pauseImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exercise-now-completing-pause-icon-ios7"]];
        _pauseImageView.hidden = YES;
        [self addSubview:_pauseImageView];
        
        self.startLabel = [[UILabel alloc] init];
        _startLabel.backgroundColor = [UIColor clearColor];
        _startLabel.textColor = [UIColor whiteColor];
        _startLabel.font = [UIFont systemFontOfSize:14.0f];
        _startLabel.text = @"Start";
        [self addSubview:_startLabel];
        
        self.pauseLabel = [[UILabel alloc] init];
        _pauseLabel.backgroundColor = [UIColor clearColor];
        _pauseLabel.textColor = [UIColor whiteColor];
        _pauseLabel.font = [UIFont systemFontOfSize:14.0f];
        _pauseLabel.text = @"Pause";
        [self addSubview:_pauseLabel];
        
        [self addTarget:self action:@selector(didTapSelf:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.startPauseBackgroundView.frame = CGRectMake(0, 1, self.frame.size.width, self.frame.size.height - 2.0f);
    
    if(self.startPauseState == ExerciseNowCompletingStartPauseButtonModePaused) {
     
        CGSize sizeForStartLabel = [_startLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f]];
        CGFloat widthForImageAndLabel = _startImageView.frame.size.width + 6.0f + sizeForStartLabel.width;
        CGFloat contentHorizontalStartPoint = (self.frame.size.width / 2) - (widthForImageAndLabel / 2);
        
        self.startImageView.frame = CGRectMake(contentHorizontalStartPoint, (self.frame.size.height / 2) - (_startImageView.frame.size.height / 2), _startImageView.frame.size.width, _startImageView.frame.size.height);
        _startLabel.frame = CGRectMake(contentHorizontalStartPoint + _startImageView.frame.size.width + 6.0f, (self.frame.size.height / 2) - (sizeForStartLabel.height / 2), sizeForStartLabel.width, sizeForStartLabel.height);
        
    } else {
        
        CGSize sizeForPauseLabel = [_pauseLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f]];
        CGFloat widthForImageAndLabel = _pauseImageView.frame.size.width + 6.0f + sizeForPauseLabel.width;
        CGFloat contentHorizontalStartPoint = (self.frame.size.width / 2) - (widthForImageAndLabel / 2);
        
        self.pauseImageView.frame = CGRectMake(contentHorizontalStartPoint, (self.frame.size.height / 2) - (_pauseImageView.frame.size.height / 2), _pauseImageView.frame.size.width, _pauseImageView.frame.size.height);
        _pauseLabel.frame = CGRectMake(contentHorizontalStartPoint + _startImageView.frame.size.width + 6.0f, (self.frame.size.height / 2) - (sizeForPauseLabel.height / 2), sizeForPauseLabel.width, sizeForPauseLabel.height);
    }
}

#pragma mark - Private Methods
- (void)didTapSelf:(id)sender {
    
    if(self.startPauseState == ExerciseNowCompletingStartPauseButtonModePaused) {
        self.startPauseState = ExerciseNowCompletingStartPauseButtonModePlaying;
    } else {
        self.startPauseState = ExerciseNowCompletingStartPauseButtonModePaused;
    }
}

- (void)setStartPauseState:(ExerciseNowCompletingStartPauseButtonMode)startPauseState {
    _startPauseState = startPauseState;
    
    if(startPauseState == ExerciseNowCompletingStartPauseButtonModePaused) {
        _startPauseBackgroundView.backgroundColor = kTintColour;
        _startLabel.hidden = NO;
        _startImageView.hidden = NO;
        _pauseLabel.hidden = YES;
        _pauseImageView.hidden = YES;
        
    } else {
        
        _startPauseBackgroundView.backgroundColor = RGBCOLOR(180, 180, 180);
        _startLabel.hidden = YES;
        _startImageView.hidden = YES;
        _pauseLabel.hidden = NO;
        _pauseImageView.hidden = NO;
    }
    
    [self setNeedsLayout];
}

- (void)setStartPauseEnabled:(BOOL)startPauseEnabled {
    _startPauseEnabled = startPauseEnabled;
    
    if(startPauseEnabled) {
        
        self.enabled = YES;
        _startPauseBackgroundView.hidden = NO;
        _startLabel.alpha = 1.0f;
        _startImageView.alpha = 1.0f;
        _pauseLabel.alpha = 1.0f;
        _pauseImageView.alpha = 1.0f;
        
    } else {
        
        self.enabled = NO;
        _startPauseBackgroundView.hidden = YES;
        _startLabel.alpha = 0.5f;
        _startImageView.alpha = 0.5f;
        _pauseLabel.alpha = 0.5f;
        _pauseImageView.alpha = 0.5f;
    }
}

@end
