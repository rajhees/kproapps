//
//  ExerciseNowCompletingStepButton.h
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ExerciseNowCompletingStepButtonTypePrevious,
    ExerciseNowCompletingStepButtonTypeNext
} ExerciseNowCompletingStepButtonType;

@interface ExerciseNowCompletingStepButton : UIButton

@property (nonatomic, assign) ExerciseNowCompletingStepButtonType type;

@property (nonatomic, strong) UILabel * stepLabel;
@property (nonatomic, strong) UIImageView * stepImageView;
@property (nonatomic, strong) UIImageView * disabledStepImageView;

- (id)initWithType:(ExerciseNowCompletingStepButtonType)type;

@end
