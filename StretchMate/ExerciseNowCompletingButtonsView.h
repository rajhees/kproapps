//
//  ExerciseNowCompletingButtonsView.h
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseNowCompletingDirectionButton.h"
#import "ExerciseNowCompletingStartPauseButton.h"

@interface ExerciseNowCompletingButtonsView : UIView

@property (nonatomic, strong) ExerciseNowCompletingDirectionButton * previousButton;
@property (nonatomic, strong) ExerciseNowCompletingStartPauseButton * startPauseButton;
@property (nonatomic, strong) ExerciseNowCompletingDirectionButton * nextButton;

@end
