//
//  ExerciseNowCompletingStepButtonsView.h
//  Exersite
//
//  Created by James Eunson on 30/05/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseInstructionTableView.h"

typedef enum {
    ButtonFrameTypePrevious,
    ButtonFrameTypeNext
} ButtonFrameType;

@interface ExerciseNowCompletingStepButtonsView : UIView

@property (nonatomic, strong) UIImageView * previousStepImageView;
@property (nonatomic, strong) UIButton * previousStepButton;
@property (nonatomic, strong) UIImageView * nextStepImageView;
@property (nonatomic, strong) UIButton * nextStepButton;

- (void)postStepChangeWithTableView:(ExerciseInstructionTableView*)tableView;

@end
