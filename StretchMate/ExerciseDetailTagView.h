//
//  ExerciseDetailTagView.h
//  StretchMate
//
//  Created by James Eunson on 25/10/12.
//  Copyright (c) 2012 James Eunson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseType.h"

#define kExerciseTagHeight 20.0f

@interface ExerciseDetailTagView : UIView

@property (nonatomic, strong) id type;

- (id)initWithFrame:(CGRect)frame andExerciseType:(id)type;
+ (CGFloat)widthForExerciseType:(id)type;

@end
