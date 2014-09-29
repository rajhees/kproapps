//
//  ExerciseNowCompletingDirectionButton.h
//  Exersite
//
//  Created by James Eunson on 27/11/2013.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ExerciseNowCompletingDirectionButtonTypePrevious,
    ExerciseNowCompletingDirectionButtonTypeNext
} ExerciseNowCompletingDirectionButtonType;

@interface ExerciseNowCompletingDirectionButton : UIButton

@property (nonatomic, strong) UIImageView * directionImageView;
@property (nonatomic, strong) UIImageView * disabledDirectionImageView;

@property (nonatomic, assign) ExerciseNowCompletingDirectionButtonType type;

@property (nonatomic, assign) BOOL directionButtonEnabled;

@end
