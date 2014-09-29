//
//  ExerciseNowCompletingButtonsView.m
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import "ExerciseNowCompletingButtonsView.h"

#define kPreviousNextButtonWidth 62.0f
#define kStartPauseButtonWidth 80.0f

@interface ExerciseNowCompletingButtonsView()

@property (nonatomic, strong) UIView * startPauseBackgroundBorderView;

@end

@implementation ExerciseNowCompletingButtonsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        
        self.previousButton = [[ExerciseNowCompletingDirectionButton alloc] init];
        _previousButton.type = ExerciseNowCompletingDirectionButtonTypePrevious;
        [self addSubview:_previousButton];
        
        self.nextButton = [[ExerciseNowCompletingDirectionButton alloc] init];
        _nextButton.type = ExerciseNowCompletingDirectionButtonTypeNext;
        [self addSubview:_nextButton];
        
        self.startPauseButton = [[ExerciseNowCompletingStartPauseButton alloc] init];
        [self addSubview:_startPauseButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.previousButton.frame = CGRectMake(0, 0, kPreviousNextButtonWidth, self.frame.size.height);
    self.nextButton.frame = CGRectMake(kPreviousNextButtonWidth + kStartPauseButtonWidth, 0, kPreviousNextButtonWidth, self.frame.size.height);
    
    _startPauseBackgroundBorderView.frame = CGRectMake(kPreviousNextButtonWidth - 4.0f, 0, kStartPauseButtonWidth + 8.0f, self.frame.size.height);
    self.startPauseButton.frame = CGRectMake(kPreviousNextButtonWidth - 4.0f, 0, kStartPauseButtonWidth + 8.0f, self.frame.size.height);
}

@end
