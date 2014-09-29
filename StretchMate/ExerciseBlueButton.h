//
//  ExerciseBlueButton.h
//  StretchMate
//
//  Created by James Eunson on 9/03/13.
//  Copyright (c) 2013 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ExerciseBlueButtonTypeInfo,
    ExerciseBlueButtonTypeVideo,
    ExerciseBlueButtonTypeZoom
} ExerciseBlueButtonType;

@interface ExerciseBlueButton : UIButton

@property (nonatomic, assign) ExerciseBlueButtonType type;
@property (nonatomic, strong) UIView * itemHighlightView;

- (id)initWithFrame:(CGRect)frame type:(ExerciseBlueButtonType)type;

@end
